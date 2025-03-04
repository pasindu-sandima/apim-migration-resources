ALTER TABLE AM_API ADD ORGANIZATION VARCHAR(100);
ALTER TABLE AM_APPLICATION ADD ORGANIZATION VARCHAR(100);
ALTER TABLE AM_API_CATEGORIES ADD ORGANIZATION VARCHAR(100);
ALTER TABLE AM_API_DEFAULT_VERSION ADD ORGANIZATION VARCHAR(100);
ALTER TABLE AM_GATEWAY_ENVIRONMENT ADD ORGANIZATION VARCHAR(100);
ALTER TABLE AM_GATEWAY_ENVIRONMENT ADD PROVIDER VARCHAR(255) DEFAULT 'wso2' WITH VALUES;
ALTER TABLE AM_API ADD GATEWAY_VENDOR VARCHAR(100) DEFAULT 'wso2' WITH VALUES;
ALTER TABLE AM_API ADD LOG_LEVEL VARCHAR(255) DEFAULT 'OFF' WITH VALUES;
ALTER TABLE AM_API ADD VERSION_COMPARABLE VARCHAR(15);

ALTER TABLE AM_KEY_MANAGER ADD TOKEN_TYPE VARCHAR(45) DEFAULT 'DIRECT' WITH VALUES;
ALTER TABLE AM_KEY_MANAGER ADD EXTERNAL_REFERENCE_ID VARCHAR(100) DEFAULT NULL;
ALTER TABLE AM_API_REVISION_METADATA ALTER COLUMN REVISION_UUID VARCHAR(255);
EXEC SP_RENAME 'AM_KEY_MANAGER.TENANT_DOMAIN', 'ORGANIZATION', 'COLUMN';


IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[AM_SYSTEM_CONFIGS]') AND TYPE IN (N'U'))
CREATE TABLE AM_SYSTEM_CONFIGS
(
  ORGANIZATION     VARCHAR(100)            NOT NULL,
  CONFIG_TYPE      VARCHAR(100)            NOT NULL,
  CONFIGURATION    VARBINARY(MAX)          NOT NULL,
  PRIMARY KEY(ORGANIZATION,CONFIG_TYPE)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[AM_OPERATION_POLICY]') AND TYPE IN (N'U'))
CREATE TABLE AM_OPERATION_POLICY (
    POLICY_UUID VARCHAR(45) NOT NULL,
    POLICY_NAME VARCHAR(300) NOT NULL,
    POLICY_VERSION VARCHAR(45) DEFAULT 'v1',
    DISPLAY_NAME VARCHAR(300) NOT NULL,
    POLICY_DESCRIPTION VARCHAR(1024),
    APPLICABLE_FLOWS VARCHAR(45) NOT NULL,
    GATEWAY_TYPES VARCHAR(45) NOT NULL,
    API_TYPES VARCHAR(45) NOT NULL,
    POLICY_PARAMETERS VARBINARY(MAX),
    ORGANIZATION VARCHAR(100),
    POLICY_CATEGORY VARCHAR(45) NOT NULL,
    POLICY_MD5 VARCHAR(45) NOT NULL,
    PRIMARY KEY(POLICY_UUID)
);


IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[AM_OPERATION_POLICY_DEFINITION]') AND TYPE IN (N'U'))
CREATE TABLE AM_OPERATION_POLICY_DEFINITION (
   DEFINITION_ID INTEGER IDENTITY(1,1),
   POLICY_UUID VARCHAR(45) NOT NULL,
   POLICY_DEFINITION VARBINARY(MAX) NOT NULL,
   GATEWAY_TYPE VARCHAR(20) NOT NULL,
   DEFINITION_MD5 VARCHAR(45) NOT NULL,
   UNIQUE (POLICY_UUID, GATEWAY_TYPE),
   FOREIGN KEY (POLICY_UUID) REFERENCES AM_OPERATION_POLICY(POLICY_UUID) ON DELETE CASCADE,
   PRIMARY KEY(DEFINITION_ID)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[AM_COMMON_OPERATION_POLICY]') AND TYPE IN (N'U'))
CREATE TABLE AM_COMMON_OPERATION_POLICY (
   COMMON_POLICY_ID INTEGER IDENTITY(1,1),
   POLICY_UUID VARCHAR(45) NOT NULL,
   FOREIGN KEY (POLICY_UUID) REFERENCES AM_OPERATION_POLICY(POLICY_UUID) ON DELETE CASCADE,
   PRIMARY KEY(COMMON_POLICY_ID)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[AM_API_OPERATION_POLICY]') AND TYPE IN (N'U'))
CREATE TABLE AM_API_OPERATION_POLICY (
   API_SPECIFIC_POLICY_ID INTEGER IDENTITY(1,1),
   POLICY_UUID VARCHAR(45) NOT NULL,
   API_UUID VARCHAR(45) NOT NULL,
   REVISION_UUID VARCHAR(45),
   CLONED_POLICY_UUID VARCHAR(45),
   FOREIGN KEY (POLICY_UUID) REFERENCES AM_OPERATION_POLICY(POLICY_UUID) ON DELETE CASCADE,
   PRIMARY KEY(API_SPECIFIC_POLICY_ID)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[AM_API_OPERATION_POLICY_MAPPING]') AND TYPE IN (N'U'))
CREATE TABLE AM_API_OPERATION_POLICY_MAPPING (
   OPERATION_POLICY_MAPPING_ID INTEGER IDENTITY(1,1),
   URL_MAPPING_ID INTEGER NOT NULL,
   POLICY_UUID VARCHAR(45) NOT NULL,
   POLICY_ORDER INTEGER NOT NULL,
   DIRECTION VARCHAR(10) NOT NULL,
   PARAMETERS VARCHAR(1024) NOT NULL,
   FOREIGN KEY (URL_MAPPING_ID) REFERENCES AM_API_URL_MAPPING(URL_MAPPING_ID) ON DELETE CASCADE,
   FOREIGN KEY (POLICY_UUID) REFERENCES AM_OPERATION_POLICY(POLICY_UUID) ON DELETE CASCADE,
   PRIMARY KEY(OPERATION_POLICY_MAPPING_ID)
);

IF NOT EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[AM_DEPLOYED_REVISION]') AND TYPE IN (N'U'))
CREATE TABLE AM_DEPLOYED_REVISION (
  NAME VARCHAR(255) NOT NULL,
  VHOST VARCHAR(255) NULL,
  REVISION_UUID VARCHAR(255) NOT NULL,
  DEPLOYED_TIME DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (NAME, REVISION_UUID),
  FOREIGN KEY (REVISION_UUID) REFERENCES AM_REVISION(REVISION_UUID) ON UPDATE CASCADE ON DELETE CASCADE
);

--ALTER TABLE AM_API ADD CONSTRAINT API_UUID_CONSTRAINT UNIQUE(API_UUID);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[AM_API_ENVIRONMENT_KEYS]') AND TYPE IN (N'U'))
CREATE TABLE AM_API_ENVIRONMENT_KEYS
(
    UUID            VARCHAR(45)  NOT NULL,
    ENVIRONMENT_ID  VARCHAR(45)  NOT NULL,
    API_UUID        VARCHAR(256) NOT NULL,
    PROPERTY_CONFIG VARBINARY(MAX) DEFAULT NULL,
    UNIQUE (ENVIRONMENT_ID, API_UUID),
    FOREIGN KEY (API_UUID) REFERENCES AM_API (API_UUID) ON DELETE CASCADE,
    PRIMARY KEY (UUID)
);

-- Changes introduced with H2 upgrade --
EXEC sp_rename 'AM_BLOCK_CONDITIONS.VALUE', 'BLOCK_CONDITION', 'COLUMN';
EXEC sp_rename 'AM_APPLICATION_ATTRIBUTES.VALUE', 'APP_ATTRIBUTE', 'COLUMN';
