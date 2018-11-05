SELECT /* Failure analysis on a certain asset class. (Also could be filtered by asset model.) */
    wo_id
     , wo_failure_mode_name                  AS 故障模式
     , wo_failure_mechanism_subdivision_name AS 故障机制
     , wo_failure_cause_subdivision_name     AS 故障原因
     , wo_maintenance_activity_name          AS 解决办法
     , wo_history.asset_code                 AS 设备编码
     , wo_history.asset_name                 AS 设备名称
     , asset_model                           AS 型号
FROM wo_history
       INNER JOIN asset_list ON wo_history.asset_id = asset_list.asset_id
WHERE (asset_class_code = :asset_class_code)
  AND ((:asset_model = '') OR (:asset_model = asset_model))
ORDER BY wo_failure_mode_name, wo_failure_mechanism_subdivision_name, wo_failure_cause_subdivision_name,
  wo_maintenance_activity_name
;

-- Part 2:
SELECT wo_id               AS 工单号
     , wo_name             AS 工单名称
     , asset_code          AS 设备编码
     , asset_name          AS 设备名称
     , wo_responsible_name AS 负责人
     , wo_creation_time    AS 创建时间
     , wo_finish_time      AS 完成时间
FROM wo_history
WHERE :cell IN (wo_failure_mode_name,
                wo_failure_mechanism_subdivision_name,
                wo_failure_cause_subdivision_name,
                wo_maintenance_activity_name)