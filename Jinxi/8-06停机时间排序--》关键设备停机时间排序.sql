-- 06停机时间排序--》关键设备停机时间排序
SELECT
    concat(location_code, " ", location_name) '位置'
  , concat(asset_code, " ", asset_name)       '设备'
  , parameter_reading_value                   '停机时间'
FROM
  (SELECT
     location_lft
     , location_rgt
   FROM asset_location
   WHERE location_id = :location_id) AS T,
  asset_parameter_reading
  LEFT JOIN asset_parameter ON asset_parameter_reading.parameter_id = asset_parameter.parameter_id
  LEFT JOIN asset_list ON asset_parameter.asset_id = asset_list.asset_id
  LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
  LEFT JOIN mic_criticality ON asset_list.criticality_id = mic_criticality.criticality_id
WHERE
  asset_nature = 0
  AND parameter_name = '工艺停机时间'
  AND parameter_reading_time BETWEEN :start_date AND :end_date
  AND criticality_code = :criticality_code
  AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
ORDER BY parameter_reading_value DESC;
--

SELECT
    wo_list_task.wo_id '工单号'
  , asset_code         '设备编码'
  , asset_name         '设备名称'
  , task_id            '任务号'
  , wo_task_remark     '停机原因'
FROM
  wo_list_task
  LEFT JOIN wo_list ON wo_list_task.wo_id = wo_list.wo_id
  LEFT JOIN asset_list ON wo_list.wo_asset_id = asset_list.asset_id
WHERE asset_code = substring_index(:cell, ' ', 1);