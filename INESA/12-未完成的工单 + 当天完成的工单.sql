/* 未完成的工单 + 当天完成的工单。 */
SELECT asset_code      AS 设备编码
     , asset_name      AS 设备名称
     , wo_id           AS 工单号
     , wo_failure_time AS 故障发生
     , ''              AS 故障修复
     , wo_name         AS 故障内容
     , wo_feedback     AS 解决情况
FROM wo_list
       INNER JOIN asset_list ON wo_list.wo_asset_id = asset_list.asset_id
WHERE wo_type_id = 1
  AND wo_status < 6

UNION ALL

SELECT asset_code      AS 设备编码
     , asset_name      AS 设备名称
     , wo_id           AS 工单号
     , wo_failure_time AS 故障发生
     , wo_finish_time  AS 故障修复
     , wo_name         AS 故障内容
     , wo_feedback     AS 解决情况
FROM wo_list
       INNER JOIN asset_list ON wo_list.wo_asset_id = asset_list.asset_id
WHERE wo_type_id = 1
  AND wo_status >= 6
  AND wo_finish_time BETWEEN date(now()) AND now()
;
