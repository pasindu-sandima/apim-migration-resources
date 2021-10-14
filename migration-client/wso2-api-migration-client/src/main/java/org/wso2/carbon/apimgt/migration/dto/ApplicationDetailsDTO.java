package org.wso2.carbon.apimgt.migration.dto;

public class ApplicationDetailsDTO {
    String appName;
    String currentSPAppName;
    String appSubscriber;
    String consumerKey;
    String keyType;
    String createdBy;
    String userDomain;
    String userName;

    public String getAppName() {

        return appName;
    }

    public void setAppName(String appName) {

        this.appName = appName;
    }

    public String getAppSubscriber() {

        return appSubscriber;
    }

    public void setAppSubscriber(String appSubscriber) {

        this.appSubscriber = appSubscriber;
    }

    public String getConsumerKey() {

        return consumerKey;
    }

    public void setConsumerKey(String consumerKey) {

        this.consumerKey = consumerKey;
    }

    public String getCreatedBy() {

        return createdBy;
    }

    public void setCreatedBy(String createdBy) {

        this.createdBy = createdBy;
    }

    public String getKeyType() {

        return keyType;
    }

    public void setKeyType(String keyType) {

        this.keyType = keyType;
    }

    public String getCurrentSPAppName() {

        return currentSPAppName;
    }

    public void setCurrentSPAppName(String currentSPAppName) {

        this.currentSPAppName = currentSPAppName;
    }

    public String getUserDomain() {

        return userDomain;
    }

    public void setUserDomain(String userDomain) {

        this.userDomain = userDomain;
    }

    public String getUserName() {

        return userName;
    }

    public void setUserName(String userName) {

        this.userName = userName;
    }
}
