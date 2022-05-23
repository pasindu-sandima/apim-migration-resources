package org.wso2.carbon.apimgt.migration.migrator.client;
/*
 * Copyright (c) 2022, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.wso2.carbon.apimgt.migration.APIMigrationException;
import org.wso2.carbon.apimgt.migration.migrator.VersionMigrator;
import org.wso2.carbon.apimgt.migration.migrator.Utility;
import org.wso2.carbon.apimgt.migration.migrator.commonMigrators.PreDBScriptMigrator;
import org.wso2.carbon.apimgt.migration.migrator.v400.V400DBDataMigrator;
import org.wso2.carbon.apimgt.migration.migrator.v400.V400RegistryResourceMigrator;
import org.wso2.carbon.user.api.UserStoreException;

import java.io.File;

public class V400Migration extends VersionMigrator {
    private static final Log log = LogFactory.getLog(V400Migration.class);
    private final String PRE_MIGRATION_SCRIPTS_PATH = Utility.PRE_MIGRATION_SCRIPT_DIR + "migration-3.2.0_to_4.0.0"
            + File.separator;
    private final String V400_RXT_PATH = Utility.RXT_DIR + "4.0.0" + File.separator;

    public V400Migration() throws UserStoreException {
    }

    @Override
    public String getPreviousVersion() {
        return "3.2.0";
    }

    @Override
    public String getCurrentVersion() {
        return "4.0.0";
    }

    @Override
    public void migrate() throws UserStoreException, APIMigrationException {
        log.info("Starting migration from " + getPreviousVersion() + " to " + getCurrentVersion() + "...");
        PreDBScriptMigrator preDBScriptMigrator = new PreDBScriptMigrator(PRE_MIGRATION_SCRIPTS_PATH);
        preDBScriptMigrator.run();
        V400DBDataMigrator v400DBDataMigrator = new V400DBDataMigrator();
        v400DBDataMigrator.migrate();
        V400RegistryResourceMigrator v400RegistryResourceMigrator = new V400RegistryResourceMigrator(V400_RXT_PATH);
        v400RegistryResourceMigrator.migrate();
        log.info("Completed migration from " + getPreviousVersion() + " to " + getCurrentVersion() + "...");
    }
}