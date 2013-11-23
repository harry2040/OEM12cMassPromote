alter session set CURRENT_SCHEMA=SYSMAN;
select 'add_target -name="' || ManagementEntityEO.ENTITY_NAME || '" -type="rac_database" -host="' ||
ManagementEntityEO.HOST_NAME || 
'" -monitor_mode="1" -properties="ServiceName:'||
(SELECT PROPERTY_VALUE FROM MGMT_TARGET_PROPERTIES WHERE TARGET_GUID = ManagementEntityEO.ENTITY_GUID AND
(UPPER(PROPERTY_NAME) LIKE '%SERVICENAME%')) ||';ClusterName:'||
(SELECT PROPERTY_VALUE FROM MGMT_TARGET_PROPERTIES WHERE TARGET_GUID = ManagementEntityEO.ENTITY_GUID AND
(UPPER(PROPERTY_NAME) LIKE '%CLUSTERNAME%')) ||'" -instances="'||
(select listagg(sub.entity_name,':oracle_database;') within group (order by sub.entity_name) FROM GC_MANAGEABLE_ENTITIES sub
where sub.ENTITY_TYPE='oracle_database' and sub.entity_name like ManagementEntityEO.ENTITY_NAME||'%')||':oracle_database”'
FROM GC_MANAGEABLE_ENTITIES ManagementEntityEO,MGMT_TARGET_TYPES ManagementEntityTypeEO
WHERE ManagementEntityEO.PROMOTE_STATUS=1
AND ManagementEntityEO.MANAGE_STATUS=1
AND ManagementEntityEO.ENTITY_TYPE!= 'host'
AND ManagementEntityEO.ENTITY_TYPE='rac_database'
AND ManagementEntityEO.ENTITY_TYPE= ManagementEntityTypeEO.TARGET_TYPE
AND (NOT EXISTS(SELECT 1 FROM
mgmt_type_properties mtp WHERE mtp.target_type= ManagementEntityEO.entity_type AND mtp.property_name ='DISCOVERY_FWK_OPTOUT'AND
mtp.property_value='1'));

