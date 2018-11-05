USE hh7;
-- Part 1: list all the assets and its failure times by location.
SELECT
  asset_list.asset_code 设备编码,
  asset_list.asset_name 设备名称,
  asset_model           型号,
  asset_serial_number   序列号,
  wo_failure_mode_name  故障模式,
  count(wo_id)          出现次数
FROM
  (SELECT
     location_lft,
     location_rgt
   FROM asset_location
   WHERE location_id = :location_id) AS T,
  asset_list
  JOIN asset_location ON asset_list.location_id = asset_location.location_id
  RIGHT JOIN wo_history ON asset_list.asset_code = wo_history.asset_code
WHERE asset_list.asset_nature = 0
      AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
      AND wo_type_type = 'CORR'
      AND asset_class_code LIKE
          CASE WHEN :asset_class_code <> ''
            THEN :asset_class_code
          ELSE '%' END
      AND asset_model LIKE
          CASE WHEN :asset_model <> ''
            THEN :asset_model
          ELSE '%' END
      AND asset_serial_number LIKE
          CASE WHEN :asset_serial_number <> ''
            THEN :asset_serial_number
          ELSE '%' END
GROUP BY asset_list.asset_code, wo_failure_mode_name;
--

-- Part 2: list all the work orders of selected asset.
SELECT
  wo_id                                                                            工单号,
  wo_name                                                                          工单名称,
  asset_code                                                                       设备编码,
  asset_name                                                                       设备名称,
  wo_failure_time                                                                  故障时间,
  wo_finish_time                                                                   完成时间,
  concat(wo_failure_mode_code, wo_failure_mode_name)                               故障模式,
  concat(wo_failure_mechanism_subdivision_code, wo_failure_cause_subdivision_name) 故障机制,
  concat(wo_failure_cause_subdivision_code, wo_failure_cause_subdivision_name)     故障原因,
  concat(wo_maintenance_activity_code, wo_maintenance_activity_name)               解决办法
FROM wo_history
WHERE wo_failure_mode_name = :cell AND asset_code = :row;
--

SHOW CREATE TABLE asset_list
