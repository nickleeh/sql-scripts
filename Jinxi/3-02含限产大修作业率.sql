SELECT
  /*
      含限产大修作业率 = (总时间 - 计划检修 - 工艺停机 - 工艺故障 - 设备故障) / 总时间
      总工作时间 = 用了维护计划以后，选定时间段内"设备当天运行时间"的加和
  */
  --
    reading_date AS xkey
  , round((total_work_time - planned_downtime - tech_downtime -
           tech_failure - asset_failure_time) / total_work_time * 100,
          2)        '含限产大修作业率'

FROM
  #   (SELECT sum(parameter_reading_value) total_work_time
  #    FROM
  #      (SELECT
  #         location_lft
  #         , location_rgt
  #       FROM asset_location
  #       WHERE location_id = :location_id) AS T,
  #      asset_parameter_reading
  #      LEFT JOIN asset_parameter ON asset_parameter_reading.parameter_id = asset_parameter.parameter_id
  #      LEFT JOIN asset_list ON asset_parameter.asset_id = asset_list.asset_id
  #      LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
  #    WHERE parameter_name = '总工作时间'
  #          AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
  #          AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)) total_work_time,

  (SELECT
       date(parameter_reading_time) reading_date
     , sum(parameter_reading_value) total_work_time
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
   WHERE parameter_name = '设备当天运行时间'
         AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
         AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)
   GROUP BY DATE(parameter_reading_time)) total_work_time, -- 总工作时间

  (SELECT sum(parameter_reading_value) asset_failure_time
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
   WHERE parameter_name = '设备机械故障停机时间'
         AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
         AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)) asset_failure_time,

  (SELECT sum(parameter_reading_value) planned_downtime
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
   WHERE parameter_name = '计划检修停机时间'
         AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
         AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)) planned_downtime,

  (SELECT sum(parameter_reading_value) tech_downtime
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
   WHERE parameter_name = '工艺停机时间'
         AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
         AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)) tech_downtime,

  (SELECT sum(parameter_reading_value) tech_failure
   FROM (SELECT
           location_lft
           , location_rgt
         FROM asset_location
         WHERE location_id = :location_id) AS T,
     asset_parameter_reading
     LEFT JOIN asset_parameter ON asset_parameter_reading.parameter_id = asset_parameter.parameter_id
     LEFT JOIN asset_list ON asset_parameter.asset_id = asset_list.asset_id
     LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
   WHERE parameter_name = '工艺故障停机时间'
         AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
         AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)) tech_failure,

  (SELECT sum(parameter_reading_value) total_downtime
   FROM (SELECT
           location_lft
           , location_rgt
         FROM asset_location
         WHERE location_id = :location_id) AS T,
     asset_parameter_reading
     LEFT JOIN asset_parameter ON asset_parameter_reading.parameter_id = asset_parameter.parameter_id
     LEFT JOIN asset_list ON asset_parameter.asset_id = asset_list.asset_id
     LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
   WHERE parameter_name = '总停机时间'
         AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
         AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)) total_downtime,

  (SELECT sum(parameter_reading_value) accessment_rate
   FROM (SELECT
           location_lft
           , location_rgt
         FROM asset_location
         WHERE location_id = :location_id) AS T,
     asset_parameter_reading
     LEFT JOIN asset_parameter ON asset_parameter_reading.parameter_id = asset_parameter.parameter_id
     LEFT JOIN asset_list ON asset_parameter.asset_id = asset_list.asset_id
     LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
   WHERE parameter_name = '考核作业率'
         AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
         AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)) accessment_rate,

  (SELECT sum(parameter_reading_value) mec_downtime
   FROM (SELECT
           location_lft
           , location_rgt
         FROM asset_location
         WHERE location_id = :location_id) AS T,
     asset_parameter_reading
     LEFT JOIN asset_parameter ON asset_parameter_reading.parameter_id = asset_parameter.parameter_id
     LEFT JOIN asset_list ON asset_parameter.asset_id = asset_list.asset_id
     LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
   WHERE parameter_name = '设备机械故障停机时间'
         AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
         AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)) mec_downtime,

  (SELECT sum(parameter_reading_value) ele_downtime
   FROM (SELECT
           location_lft
           , location_rgt
         FROM asset_location
         WHERE location_id = :location_id) AS T,
     asset_parameter_reading
     LEFT JOIN asset_parameter ON asset_parameter_reading.parameter_id = asset_parameter.parameter_id
     LEFT JOIN asset_list ON asset_parameter.asset_id = asset_list.asset_id
     LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
   WHERE parameter_name = '设备电气故障停机时间'
         AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
         AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)) ele_downtime,

  (SELECT sum(parameter_reading_value) automation_downtime
   FROM (SELECT
           location_lft
           , location_rgt
         FROM asset_location
         WHERE location_id = :location_id) AS T,
     asset_parameter_reading
     LEFT JOIN asset_parameter ON asset_parameter_reading.parameter_id = asset_parameter.parameter_id
     LEFT JOIN asset_list ON asset_parameter.asset_id = asset_list.asset_id
     LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
   WHERE
     parameter_name = '设备自动化故障停机时间'
     AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
     AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)) automation_downtime,

  (SELECT sum(parameter_reading_value) repair_downtime
   FROM (SELECT
           location_lft
           , location_rgt
         FROM asset_location
         WHERE location_id = :location_id) AS T,
     asset_parameter_reading
     LEFT JOIN asset_parameter ON asset_parameter_reading.parameter_id = asset_parameter.parameter_id
     LEFT JOIN asset_list ON asset_parameter.asset_id = asset_list.asset_id
     LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
   WHERE parameter_name = '大中修停机时间'
         AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
         AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)) repair_downtime,

  (SELECT sum(parameter_reading_value) planned_maintenance_downtime
   FROM (SELECT
           location_lft
           , location_rgt
         FROM asset_location
         WHERE location_id = :location_id) AS T,
     asset_parameter_reading
     LEFT JOIN asset_parameter ON asset_parameter_reading.parameter_id = asset_parameter.parameter_id
     LEFT JOIN asset_list ON asset_parameter.asset_id = asset_list.asset_id
     LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
   WHERE parameter_name = '计划检修停机时间'
         AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
         AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)) planned_maintenance_downtime,

  (SELECT sum(parameter_reading_value) outside_downtime
   FROM (SELECT
           location_lft
           , location_rgt
         FROM asset_location
         WHERE location_id = :location_id) AS T,
     asset_parameter_reading
     LEFT JOIN asset_parameter ON asset_parameter_reading.parameter_id = asset_parameter.parameter_id
     LEFT JOIN asset_list ON asset_parameter.asset_id = asset_list.asset_id
     LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
   WHERE parameter_name = '外围影响停机时间'
         AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
         AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)) outside_downtime