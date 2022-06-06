ALTER TABLE AM_API ADD API_UUID VARCHAR(255)
/
ALTER TABLE AM_API ADD CONSTRAINT API_UUID_CONSTRAINT UNIQUE(API_UUID)
/
ALTER TABLE AM_API ADD STATUS VARCHAR(30)
/
ALTER TABLE AM_API ADD REVISIONS_CREATED INTEGER DEFAULT 0
/
ALTER TABLE AM_CERTIFICATE_METADATA ADD CERTIFICATE BLOB DEFAULT NULL
/


CREATE TABLE AM_REVISION (
            ID INTEGER NOT NULL,
            API_UUID VARCHAR(256) NOT NULL,
            REVISION_UUID VARCHAR(255) NOT NULL,
            DESCRIPTION VARCHAR(255),
            CREATED_TIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            CREATED_BY VARCHAR(255),
            PRIMARY KEY (ID, API_UUID),
            UNIQUE(REVISION_UUID))
/

CREATE TABLE AM_API_REVISION_METADATA (
    API_UUID VARCHAR(64),
    REVISION_UUID VARCHAR(64),
    API_TIER VARCHAR(128),
    UNIQUE (API_UUID,REVISION_UUID)
)
/

CREATE TABLE AM_DEPLOYMENT_REVISION_MAPPING (
            NAME VARCHAR(255) NOT NULL,
            VHOST VARCHAR(255) NULL,
            REVISION_UUID VARCHAR(255) NOT NULL,
            DISPLAY_ON_DEVPORTAL INTEGER DEFAULT 0,
            DEPLOYED_TIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (NAME, REVISION_UUID),
            FOREIGN KEY (REVISION_UUID) REFERENCES AM_REVISION(REVISION_UUID) ON DELETE CASCADE)
/

ALTER TABLE AM_API_CLIENT_CERTIFICATE ADD REVISION_UUID VARCHAR(255) DEFAULT 'Current API' NOT NULL
/
ALTER TABLE AM_API_CLIENT_CERTIFICATE DROP PRIMARY KEY
/
ALTER TABLE AM_API_CLIENT_CERTIFICATE ADD PRIMARY KEY(ALIAS,TENANT_ID, REMOVED, REVISION_UUID)
/

ALTER TABLE AM_API_URL_MAPPING ADD REVISION_UUID VARCHAR(256)
/
ALTER TABLE AM_GRAPHQL_COMPLEXITY ADD REVISION_UUID VARCHAR(256)
/
ALTER TABLE AM_API_PRODUCT_MAPPING ADD REVISION_UUID VARCHAR(256)
/

declare
    c int;
begin
    select count(*) into c from user_tables where table_name = upper('AM_GW_API_DEPLOYMENTS');
    if c = 1 then
          execute immediate 'drop table AM_GW_API_DEPLOYMENTS';
    end if;
end;
/

declare
    c int;
begin
    select count(*) into c from user_tables where table_name = upper('AM_GW_API_ARTIFACTS');
    if c = 1 then
              execute immediate 'drop table AM_GW_API_ARTIFACTS';
    end if;
end;
/

declare
c int;
begin
    select count(*) into c from user_tables where table_name = upper('AM_GW_PUBLISHED_API_DETAILS');
    if c = 1 then
                  execute immediate 'drop table AM_GW_PUBLISHED_API_DETAILS';
    end if;
end;
/

CREATE TABLE AM_GW_PUBLISHED_API_DETAILS (
  API_ID varchar(255) NOT NULL,
  TENANT_DOMAIN varchar(255),
  API_PROVIDER varchar(255),
  API_NAME varchar(255),
  API_VERSION varchar(255),
  API_TYPE varchar(50),
  PRIMARY KEY (API_ID)
)
/
CREATE TABLE AM_GW_API_ARTIFACTS (
  API_ID varchar(255) NOT NULL,
  REVISION_ID varchar(255) NOT NULL,
  ARTIFACT blob,
  TIME_STAMP TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (REVISION_ID, API_ID),
  FOREIGN KEY (API_ID) REFERENCES AM_GW_PUBLISHED_API_DETAILS(API_ID)
)
/
CREATE TABLE AM_GW_API_DEPLOYMENTS (
  API_ID VARCHAR(255) NOT NULL,
  REVISION_ID VARCHAR(255) NOT NULL,
  LABEL VARCHAR(255) NOT NULL,
  VHOST VARCHAR(255) NULL,
  PRIMARY KEY (REVISION_ID, API_ID,LABEL),
  FOREIGN KEY (API_ID) REFERENCES AM_GW_PUBLISHED_API_DETAILS(API_ID)
)
/

-- Service Catalog --
CREATE TABLE AM_SERVICE_CATALOG (
            UUID VARCHAR(36) NOT NULL,
            SERVICE_KEY VARCHAR(100) NOT NULL,
            MD5 VARCHAR(100) NOT NULL,
            SERVICE_NAME VARCHAR(255) NOT NULL,
            DISPLAY_NAME VARCHAR(255) NOT NULL,
            SERVICE_VERSION VARCHAR(30) NOT NULL,
            TENANT_ID INTEGER NOT NULL,
            SERVICE_URL VARCHAR(2048) NOT NULL,
            DEFINITION_TYPE VARCHAR(20),
            DEFINITION_URL VARCHAR(2048),
            DESCRIPTION VARCHAR(1024),
            SECURITY_TYPE VARCHAR(50),
            MUTUAL_SSL_ENABLED NUMBER(1,0) DEFAULT 0,
            CREATED_TIME TIMESTAMP NULL,
            LAST_UPDATED_TIME TIMESTAMP NULL,
            CREATED_BY VARCHAR(255),
            UPDATED_BY VARCHAR(255),
            SERVICE_DEFINITION BLOB NOT NULL,
            METADATA BLOB NOT NULL,
            PRIMARY KEY (UUID),
            CONSTRAINT SERVICE_KEY_TENANT UNIQUE(SERVICE_KEY, TENANT_ID),
            CONSTRAINT SERVICE_NAME_VERSION_TENANT UNIQUE (SERVICE_NAME, SERVICE_VERSION, TENANT_ID))
/

-- Webhooks --
CREATE TABLE AM_WEBHOOKS_SUBSCRIPTION (
            WH_SUBSCRIPTION_ID INTEGER NOT NULL,
            API_UUID VARCHAR(255) NOT NULL,
            APPLICATION_ID VARCHAR(255) NOT NULL,
            TENANT_DOMAIN VARCHAR(255) NOT NULL,
            HUB_CALLBACK_URL VARCHAR(1024) NOT NULL,
            HUB_TOPIC VARCHAR(255) NOT NULL,
            HUB_SECRET VARCHAR(2048),
            HUB_LEASE_SECONDS INTEGER,
            UPDATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            EXPIRY_AT NUMBER(19),
            DELIVERED_AT TIMESTAMP NULL,
            DELIVERY_STATE INTEGER,
            PRIMARY KEY (WH_SUBSCRIPTION_ID))
/

CREATE SEQUENCE AM_WEBHOOKS_SUBSCRIPTION_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/

CREATE OR REPLACE TRIGGER AM_WEBHOOKS_SUB_TRIGGER
		    BEFORE INSERT
            ON AM_WEBHOOKS_SUBSCRIPTION
            REFERENCING NEW AS NEW
            FOR EACH ROW
            BEGIN
                SELECT AM_WEBHOOKS_SUBSCRIPTION_SEQ.nextval INTO :NEW.WH_SUBSCRIPTION_ID FROM dual;
            END;
/

CREATE TABLE AM_WEBHOOKS_UNSUBSCRIPTION (
            API_UUID VARCHAR(255) NOT NULL,
            APPLICATION_ID VARCHAR(20) NOT NULL,
            TENANT_DOMAIN VARCHAR(255) NOT NULL,
            HUB_CALLBACK_URL VARCHAR(1024) NOT NULL,
            HUB_TOPIC VARCHAR(255) NOT NULL,
            HUB_SECRET VARCHAR(2048),
            HUB_LEASE_SECONDS INTEGER,
            ADDED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP)
/

CREATE TABLE AM_API_SERVICE_MAPPING (
    API_ID INTEGER NOT NULL,
    SERVICE_KEY VARCHAR(256) NOT NULL,
    MD5 VARCHAR(100) NOT NULL,
    TENANT_ID INTEGER NOT NULL,
    PRIMARY KEY (API_ID, SERVICE_KEY),
    FOREIGN KEY (API_ID) REFERENCES AM_API(API_ID) ON DELETE CASCADE
)
/
-- Gateway Environments Table --
CREATE TABLE AM_GATEWAY_ENVIRONMENT (
            ID INTEGER NOT NULL,
            UUID VARCHAR(45) NOT NULL,
            NAME VARCHAR(255) NOT NULL,
            TENANT_DOMAIN VARCHAR(255),
            DISPLAY_NAME VARCHAR(255) NULL,
            DESCRIPTION VARCHAR(1023) NULL,
            UNIQUE (NAME, TENANT_DOMAIN),
            UNIQUE (UUID),
            PRIMARY KEY (ID))
/
CREATE SEQUENCE AM_GATEWAY_ENV_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE OR REPLACE TRIGGER AM_GATEWAY_ENVIRONMENT_TRIGGER
		    BEFORE INSERT
            ON AM_GATEWAY_ENVIRONMENT
            REFERENCING NEW AS NEW
            FOR EACH ROW
            BEGIN
                SELECT AM_GATEWAY_ENV_SEQ.nextval INTO :NEW.ID FROM dual;
            END;
/

-- Virtual Hosts Table --
CREATE TABLE AM_GW_VHOST (
            GATEWAY_ENV_ID INTEGER,
            HOST VARCHAR(255) NOT NULL,
            HTTP_CONTEXT VARCHAR(255) NULL,
            HTTP_PORT VARCHAR(5) NOT NULL,
            HTTPS_PORT VARCHAR(5) NOT NULL,
            WS_PORT VARCHAR(5) NOT NULL,
            WSS_PORT VARCHAR(5) NOT NULL,
            FOREIGN KEY (GATEWAY_ENV_ID) REFERENCES AM_GATEWAY_ENVIRONMENT(ID) ON DELETE CASCADE,
            PRIMARY KEY (GATEWAY_ENV_ID, HOST))
/

ALTER TABLE AM_POLICY_SUBSCRIPTION ADD CONNECTIONS_COUNT INTEGER DEFAULT 0 NOT NULL
/

ALTER TABLE AM_API_COMMENTS RENAME COLUMN COMMENTED_USER TO CREATED_BY
/
ALTER TABLE AM_API_COMMENTS RENAME COLUMN DATE_COMMENTED TO CREATED_TIME
/
ALTER TABLE AM_API_COMMENTS ADD UPDATED_TIME DATE
/
ALTER TABLE AM_API_COMMENTS ADD PARENT_COMMENT_ID VARCHAR2(255) DEFAULT NULL
/
ALTER TABLE AM_API_COMMENTS ADD ENTRY_POINT VARCHAR2(20)  DEFAULT 'DEVPORTAL'
/
ALTER TABLE AM_API_COMMENTS ADD CATEGORY VARCHAR2(20) DEFAULT 'general'
/
ALTER TABLE AM_API_COMMENTS ADD FOREIGN KEY(PARENT_COMMENT_ID) REFERENCES AM_API_COMMENTS(COMMENT_ID)
/
