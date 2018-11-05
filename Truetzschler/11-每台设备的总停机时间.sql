SELECT wo_id                             AS '工单号 Work Order'
     , wo_name                           AS '工单名称 Work Order Name'
     , asset_code                        AS '设备编码 Asset Code'
     , asset_name                        AS '设备名称 Asset Name'
     , wo_creation_time                  AS '日期 Date'
     , round(wo_downtime / 3600, 2)      AS '停机时间（小时） Down Time (hour)'
     , wo_failure_cause_subdivision_name AS '故障原因 Failure Cause'
     , wo_maintenance_activity_name      AS '解决办法 Solution'
     , wo_feedback                       AS '工单反馈 Feedback'
FROM wo_history
WHERE asset_class_code LIKE if(:asset_class_code = '', '%%', :asset_class_code)
  AND wo_creation_time BETWEEN :start_date AND :end_date
  AND asset_id LIKE if(:asset_id = '', '%%', :asset_id)
  AND (:type_code = ''
         OR wo_type_code = :type_code)
  AND (:asset_id = 0 OR asset_id = :asset_id)

UNION ALL

SELECT '汇总 Summary', '', '', '', '', round(sum(wo_downtime) / 3600, 2) AS '停机时间（小时） Down Time (hour)', '', '', ''

FROM wo_history
WHERE asset_class_code LIKE if(:asset_class_code = '', '%%', :asset_class_code)
  AND wo_creation_time BETWEEN :start_date AND :end_date
  AND asset_id LIKE if(:asset_id = '', '%%', :asset_id)
  AND (:type_code = ''
         OR wo_type_code = :type_code)
  AND (:asset_id = 0 OR asset_id = :asset_id)
