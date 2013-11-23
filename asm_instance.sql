alter session set CURRENT_SCHEMA=SYSMAN;
select 'add_target -name="' || ManagementEntityEO.ENTITY_NAME || '" -type="osm_instance" -host="' ||
ManagementEntityEO.HOST_NAME || '" -credentials="UserName:sys;password:sTroNGPassWd;Role:sysdba" -properties="OracleHome:' ||
(SELECT PROPERTY_VALUE FROM MGMT_TARGET_PROPERTIES WHERE TARGET_GUID =
ManagementEntityEO.ENTITY_GUID AND
(UPPER(PROPERTY_NAME) LIKE '%HOME' AND UPPER(PROPERTY_NAME)!='MW_HOME' OR PROPERTY_NAME ='INSTALL_LOCATION') AND ROWNUM = 1)
|| ';MachineName:' || (SELECT PROPERTY_VALUE FROM MGMT_TARGET_PROPERTIES WHERE TARGET_GUID = 
ManagementEntityEO.ENTITY_GUID AND
(UPPER(PROPERTY_NAME) LIKE '%MACHINENAME')) || ';SID:' || 
(SELECT PROPERTY_VALUE FROM MGMT_TARGET_PROPERTIES WHERE TARGET_GUID = 
ManagementEntityEO.ENTITY_GUID AND
(UPPER(PROPERTY_NAME) LIKE '%SID%'))||
';Port:' ||
(SELECT PROPERTY_VALUE FROM MGMT_TARGET_PROPERTIES WHERE TARGET_GUID = 
ManagementEntityEO.ENTITY_GUID AND
(UPPER(PROPERTY_NAME) LIKE '%PORT%')) ||'"'
FROM GC_MANAGEABLE_ENTITIES ManagementEntityEO,MGMT_TARGET_TYPES ManagementEntityTypeEO
WHERE ManagementEntityEO.PROMOTE_STATUS=1
AND ManagementEntityEO.MANAGE_STATUS=1
AND ManagementEntityEO.ENTITY_TYPE!= 'host'
AND ManagementEntityEO.ENTITY_TYPE='osm_instance'
AND ManagementEntityEO.ENTITY_TYPE= ManagementEntityTypeEO.TARGET_TYPE
AND (NOT EXISTS(SELECT 1 FROM
mgmt_type_properties mtp WHERE mtp.target_type= ManagementEntityEO.entity_type AND mtp.property_name ='DISCOVERY_FWK_OPTOUT'AND
mtp.property_value='1'));

