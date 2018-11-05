SELECT
  /*
        总工作时间 = 用了维护计划以后，选定时间段内"设备当天运行时间"的加和
  */
    reading_date AS     xkey
  , @asset_failure_rate '设备故障率'
  , @tech_failure_rate  '工艺故障率'
FROM
  (SELECT
     -- 设备故障率 = 机械设备故障率+电气设备故障率+自动化设备故障率
     -- xx设备故障率 = 设备故障停机时间／总时间xx
       daily_worktime.reading_date                                                                               reading_date
     , @mec_failure_rate := mec_failure_time / daily_worktime
     , @ele_failure_rate := ele_failure_time / daily_worktime
     , @automation_failure_rate := automation_failure_time / daily_worktime
     , @asset_failure_rate := round((@mec_failure_rate + @ele_failure_rate + @automation_failure_rate) * 100, 2) '设备故障率'
     -- 工艺故障率 = 工艺故障停机时间／总时间
     , @tech_failure_rate := round(tech_failure_time / daily_worktime * 100, 2)                                  '工艺故障率'
   FROM
     (SELECT
          DATE(parameter_reading_time) reading_date
        , sum(parameter_reading_value) daily_worktime
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
      GROUP BY DATE(parameter_reading_time)) daily_worktime

     JOIN

     (SELECT
          DATE(parameter_reading_time) reading_date
        , sum(parameter_reading_value) mec_failure_time
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
            AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)
      GROUP BY DATE(parameter_reading_time)) mec_failure_time
       ON daily_worktime.reading_date = mec_failure_time.reading_date

     JOIN

     (SELECT
          DATE(parameter_reading_time) reading_date
        , sum(parameter_reading_value) ele_failure_time
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
            AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)
      GROUP BY DATE(parameter_reading_time)) ele_failure_time
       ON daily_worktime.reading_date = ele_failure_time.reading_date

     JOIN


     (SELECT
          DATE(parameter_reading_time) reading_date
        , sum(parameter_reading_value) automation_failure_time
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
        AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)
      GROUP BY DATE(parameter_reading_time)) automation_failure_time
       ON daily_worktime.reading_date = automation_failure_time.reading_date

     JOIN

     (SELECT
          DATE(parameter_reading_time) reading_date
        , sum(parameter_reading_value) tech_failure_time
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
            AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)
      GROUP BY DATE(parameter_reading_time)) tech_failure_time
       ON daily_worktime.reading_date = tech_failure_time.reading_date) alldata;