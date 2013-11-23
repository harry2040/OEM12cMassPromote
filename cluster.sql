alter session set CURRENT_SCHEMA=SYSMAN;
select 
'add_target -name="' || ManagementEntityEO.ENTITY_NAME 
|| '" -type="cluster" -host="' ||ManagementEntityEO.HOST_NAME 
|| '" -monitor_mode="1" -properties="OracleHome:' ||
(SELECT PROPERTY_VALUE FROM SYSMAN.MGMT_TARGET_PROPERTIES WHERE TARGET_GUID =
ManagementEntityEO.ENTITY_GUID AND
(UPPER(PROPERTY_NAME) LIKE '%HOME' AND UPPER(PROPERTY_NAME)!='MW_HOME' OR PROPERTY_NAME ='INSTALL_LOCATION') AND ROWNUM = 1) 
|| ';eonsPort:' || 
(SELECT PROPERTY_VALUE FROM SYSMAN.MGMT_TARGET_PROPERTIES WHERE TARGET_GUID = ManagementEntityEO.ENTITY_GUID AND
(UPPER(PROPERTY_NAME) LIKE 'EONSPORT%')) 
|| ';scanName:' || 
(SELECT PROPERTY_VALUE FROM SYSMAN.MGMT_TARGET_PROPERTIES WHERE TARGET_GUID = ManagementEntityEO.ENTITY_GUID AND
(UPPER(PROPERTY_NAME) LIKE 'SCANNAME%')) 
|| ';scanPort:' || 
(SELECT PROPERTY_VALUE FROM SYSMAN.MGMT_TARGET_PROPERTIES WHERE TARGET_GUID = ManagementEntityEO.ENTITY_GUID AND
(UPPER(PROPERTY_NAME) LIKE 'SCANPORT%'))
|| ';" -instances="' ||ManagementEntityEO.HOST_NAME||':host;'||
(select decode(b.host_name,null,'"',b.host_name||':host"')
FROM SYSMAN.GC_MANAGEABLE_ENTITIES a , SYSMAN.GC_MANAGEABLE_ENTITIES b WHERE a.PROMOTE_STATUS=1
AND a.MANAGE_STATUS=1
AND a.ENTITY_TYPE!= 'host'
AND a.ENTITY_TYPE='cluster'
and b.HOST_NAME like REGEXP_REPLACE(a.HOST_NAME, '([a-z]+)[0-9].*', '\1%')
and b.host_name <> a.host_name
and b.entity_type='host'
and a.host_name=ManagementEntityEO.host_name
)
FROM SYSMAN.GC_MANAGEABLE_ENTITIES ManagementEntityEO,SYSMAN.MGMT_TARGET_TYPES ManagementEntityTypeEO
WHERE ManagementEntityEO.PROMOTE_STATUS=1
AND ManagementEntityEO.MANAGE_STATUS=1
AND ManagementEntityEO.ENTITY_TYPE!= 'host'
AND ManagementEntityEO.ENTITY_TYPE='cluster'
AND ManagementEntityEO.ENTITY_TYPE= ManagementEntityTypeEO.TARGET_TYPE
AND (NOT EXISTS(SELECT 1 FROM
SYSMAN.mgmt_type_properties mtp WHERE mtp.target_type= ManagementEntityEO.entity_type AND mtp.property_name ='DISCOVERY_FWK_OPTOUT'AND
mtp.property_value='1'));
