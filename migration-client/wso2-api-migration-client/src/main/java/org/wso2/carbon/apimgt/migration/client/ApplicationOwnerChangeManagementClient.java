/*
 * Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.wso2.carbon.apimgt.migration.client;

import com.google.gson.Gson;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.wso2.carbon.apimgt.impl.utils.APIUtil;
import org.wso2.carbon.apimgt.migration.APIMigrationException;
import org.wso2.carbon.apimgt.migration.client.internal.ServiceHolder;
import org.wso2.carbon.apimgt.migration.dao.APIMgtDAO;
import org.wso2.carbon.apimgt.migration.dto.ApplicationDetailsDTO;
import org.wso2.carbon.identity.application.common.IdentityApplicationManagementException;
import org.wso2.carbon.identity.application.common.model.ServiceProvider;
import org.wso2.carbon.identity.application.mgt.ApplicationManagementService;
import org.wso2.carbon.user.api.Tenant;
import org.wso2.carbon.user.api.UserStoreException;
import org.wso2.carbon.user.api.UserStoreManager;
import org.wso2.carbon.user.core.tenant.TenantManager;
import org.wso2.carbon.utils.multitenancy.MultitenantUtils;

import java.util.List;

/**
 * This Class is used to update the SP APP name, Role Name, and IDN Application name if the owner of the Application is transferred
 * From APIM 3.2.0, when we transfer the owner of an application, SP Name, Role Name changes with the transferred user.
 * Eg: If the Application name is PizzaApp created by user chris, SP app name would be chris_PizzaApp_Production and the role
 * associated with that app would be Application/chris_PizzaApp_Production. Once we transfer this to kim user, before 3.x,
 * owner transfer happens, but we don not update the created application names or role names. From 3.2.0 onwards, we update
 * these such that SP app would be changed to kim_PizzaApp_Production and role to Application/kim_PizzaApp_Production.
 * <p>
 * With this class, we will query the tables and regenerate the expected SP APP name. If that name differs with the current
 * SP app name, tool will update the Service Provider with the expected name.
 */
public class ApplicationOwnerChangeManagementClient extends MigrationClientBase {

    private static final Log log = LogFactory.getLog(ApplicationOwnerChangeManagementClient.class);

    APIMgtDAO apiMgtDAO = APIMgtDAO.getInstance();
    ApplicationManagementService applicationManagementService = ServiceHolder.getApplicationManagementService();

    public ApplicationOwnerChangeManagementClient(String tenantArguments, String blackListTenantArguments,
                                                  String tenantRange,
                                                  TenantManager tenantManager) throws UserStoreException {

        super(tenantArguments, blackListTenantArguments, tenantRange, tenantManager);
    }

    public void updateApplicationOwner(boolean overrideSPAppName) throws APIMigrationException {

        if (overrideSPAppName) {
            log.info("Override SP name is used. If a difference between current SP app name and expected SP name is found, " +
                    "current SP app name will be updated with the expected SP name.");
        }
        for (Tenant tenant : getTenantsArray()) {
            List<ApplicationDetailsDTO> appDetailDTOList = apiMgtDAO.retrieveApplicationInfoForTenant(tenant);
            for (ApplicationDetailsDTO appDetailsDTO : appDetailDTOList) {
                try {
                    UserStoreManager userStoreManager = ServiceHolder.getRealmService()
                            .getTenantUserRealm(tenant.getId()).getUserStoreManager();
                    String appOwner = MultitenantUtils.getTenantAwareUsername(
                            appDetailsDTO.getAppSubscriber());
                    boolean existingUser = userStoreManager.isExistingUser(appOwner);
                    if (existingUser) {
                        String currentSPAppName = appDetailsDTO.getCurrentSPAppName();
                        String qualifiedSPName =
                                APIUtil.replaceEmailDomain(appOwner).replace("/", "_")
                                        + "_" + appDetailsDTO.getAppName() + "_" + appDetailsDTO.getKeyType();
                        if (!qualifiedSPName.equals(currentSPAppName)) {
                            log.info("Current SP name " + currentSPAppName
                                    + " does not match with expected SP name of " + qualifiedSPName);
                            log.info("Application name from APP table: " + appDetailsDTO.getAppName()
                                    + ", SP name from IDN table: " + appDetailsDTO.getCurrentSPAppName()
                                    + ", user from IDN table: " + appDetailsDTO.getUserName()
                                    + ", user from SUB table: " + appDetailsDTO.getAppSubscriber()
                                    + " and user from APP table: " + appDetailsDTO.getCreatedBy());
                            ServiceProvider serviceProvider = applicationManagementService
                                    .getServiceProvider(currentSPAppName, tenant.getDomain());
                            if (serviceProvider != null) {
                                log.info("SP name has to update from " + serviceProvider.getApplicationName()
                                        + " to " + qualifiedSPName);
                                if (overrideSPAppName) {
                                    ServiceProvider clonedSP = cloneServiceProvider(serviceProvider);
                                    clonedSP.setApplicationName(qualifiedSPName);
                                    try {
                                        applicationManagementService.updateApplication(clonedSP, tenant.getDomain(),
                                                appDetailsDTO.getAppSubscriber());
                                        log.info("SP name updated for " + serviceProvider.getApplicationName()
                                                + " with " + qualifiedSPName);
                                    } catch (Exception e) {
                                        log.error("Error updating the SP " + serviceProvider.getApplicationName()
                                                + " in tenant " + tenant.getDomain(), e);
                                    }
                                }
                            } else {
                                log.error("A valid SP is not found for " + currentSPAppName + " in tenant " +
                                        tenant.getDomain());
                            }
                        }
                    } else {
                        log.error("User " + MultitenantUtils
                                .getTenantAwareUsername(appDetailsDTO.getAppSubscriber()) + " from tenant domain "
                                + tenant.getDomain() + " does not exists");
                    }
                } catch (IdentityApplicationManagementException | UserStoreException e) {
                    log.error("Error retrieving the SP for App " + appDetailsDTO.getAppName() + " in tenant " +
                            tenant.getDomain(), e);
                }
            }
        }
    }

    /**
     * Create a deep copy of the input Service Provider.
     *
     * @param serviceProvider Service Provider.
     * @return Clone of serviceProvider.
     */
    public static ServiceProvider cloneServiceProvider(ServiceProvider serviceProvider) {

        Gson gson = new Gson();
        ServiceProvider clonedServiceProvider = gson.fromJson(gson.toJson(serviceProvider), ServiceProvider.class);
        return clonedServiceProvider;
    }

}
