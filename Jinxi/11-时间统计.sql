-- 时间统计（饼图）
SELECT
  label
  , ifnull(value, 0) value
FROM

  (SELECT
       '设备当天运行时间' AS                'label'
     , sum(parameter_reading_value) 'value'
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
   WHERE parameter_name = '设备当天运行时间' AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)
         AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt) asset_run_time

UNION ALL

SELECT
    '外围影响停机时间'                   label
  , sum(parameter_reading_value) value
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
WHERE parameter_name = '外围影响停机时间' AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)
      AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt

UNION ALL

SELECT
    '大中修停机时间'                    label
  , sum(parameter_reading_value) value
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
WHERE parameter_name = '大中修停机时间' AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)
      AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt


UNION ALL

SELECT
    '计划检修停机时间'                   label
  , sum(parameter_reading_value) value
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
WHERE parameter_name = '计划检修停机时间' AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)
      AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt

UNION ALL

SELECT
    '工艺停机时间'                     label
  , sum(parameter_reading_value) value
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
WHERE parameter_name = '工艺停机时间' AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)
      AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt

UNION ALL

SELECT
    '工艺故障停机时间'                   label
  , sum(parameter_reading_value) value
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
WHERE parameter_name = '工艺故障停机时间' AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)
      AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt

UNION ALL

SELECT
    '设备机械故障停机时间'                 label
  , sum(parameter_reading_value) value
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
WHERE parameter_name = '设备机械故障停机时间' AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)
      AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt

UNION ALL

SELECT
    '设备电气故障停机时间'                 label
  , sum(parameter_reading_value) value
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
WHERE parameter_name = '设备电气故障停机时间' AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)
      AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt

UNION ALL

SELECT
    '设备自动化故障停机时间'                label
  , sum(parameter_reading_value) value
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
WHERE parameter_name = '设备自动化故障停机时间' AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)
      AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt;