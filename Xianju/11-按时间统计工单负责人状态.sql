SELECT wo_list.wo_id                                            AS 工单号
     , wo_creation_time                                         AS 创建时间
     , wo_name                                                  AS 内容
     , concat(asset_code, asset_name)                           AS 资产
     , mr_requester                                             AS 申请人
     , wo_creator                                               AS 创建人
     , admin_employee_responsible.employee_name                 AS 负责人
     , group_concat(admin_employee.employee_name SEPARATOR "，") AS 安排人员
     , type_name                                                AS 类别
     , status_name_cn                                           AS 状态
FROM (SELECT location_lft, location_rgt FROM asset_location WHERE location_id = :location_id) AS scope,
     wo_list
       LEFT JOIN asset_list ON wo_list.wo_asset_id = asset_list.asset_id
       LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
       LEFT JOIN wo_list_employee ON wo_list.wo_id = wo_list_employee.wo_id
       LEFT JOIN admin_employee ON wo_list_employee.employee_id = admin_employee.employee_id
       LEFT JOIN admin_employee admin_employee_responsible
         ON wo_list.wo_responsible_id = admin_employee_responsible.employee_id
       LEFT JOIN mic_type ON wo_list.wo_type_id = mic_type.type_id
       LEFT JOIN mic_status ON wo_list.wo_status = mic_status.status_id
       LEFT JOIN mr_list ON wo_list.mr_id = mr_list.mr_id
WHERE wo_creation_time BETWEEN :start_date AND :end_date
  AND asset_location.location_lft BETWEEN scope.location_lft AND scope.location_rgt
GROUP BY wo_list.wo_id