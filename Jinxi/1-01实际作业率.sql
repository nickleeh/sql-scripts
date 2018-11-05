SELECT
  /*
      实际作业率 = (总工作时间-总停机时间) / 总工作时间
      总工作时间 = 用了维护计划以后，选定时间段内"设备当天运行时间"的加和
      总停机时间 = 外围影响停机时间 + 大中修停机时间 + 计划检修停机时间 + 工艺停机时间 + 工艺故障停机时间 + 设备机械故障停机时间 +
                  设备电气故障停机时间 + 设备自动化故障停机时间
	  2018-01-23
  */

    daily_worktime.reading_date AS                                                      xkey
  , round((daily_worktime - (outer_influence_downtime + repairment_downtime + scheduled_downtime + tech_downtime +
                             tech_failure_downtime + mec_failure_downtime + ele_failure_downtime +
                             automatation_failure_downtime)) / daily_worktime * 100, 2) '实际作业率'
  , CASE
    WHEN :location_id = 3 THEN 99.50 -- 01-01 竖炉
    WHEN :location_id = 4 THEN 96.67 -- 01-02 烧结机
    #         when :location_id = 01-03 then
    #         when :location_id = 02-01 then
    #         when :location_id = 02-02 then
    #         when :location_id = 03-01 then
    #         when :location_id = 03-02 then
    #         when :location_id = 04-01 then
    #         when :location_id = 05-01 then
    #         when :location_id = 06-01 then
    #         when :location_id = 06-02 then
    END                         AS                                                      '考核作业率'
FROM
  (SELECT
       date(parameter_reading_time) reading_date
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
   GROUP BY DATE(parameter_reading_time)) daily_worktime -- 总工作时间

  LEFT JOIN

  (SELECT
       DATE(parameter_reading_time) reading_date
     , sum(parameter_reading_value) outer_influence_downtime
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
   WHERE parameter_name = '外围影响停机时间'
         AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
         AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)
   GROUP BY DATE(parameter_reading_time)) outer_influence_downtime -- 外围影响停机时间
    ON daily_worktime.reading_date = outer_influence_downtime.reading_date

  LEFT JOIN

  (SELECT
       DATE(parameter_reading_time) reading_date
     , sum(parameter_reading_value) repairment_downtime
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
   WHERE parameter_name = '大中修停机时间'
         AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
         AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)
   GROUP BY DATE(parameter_reading_time)) repairment_downtime  -- 大中修停机时间
    ON daily_worktime.reading_date = repairment_downtime.reading_date

  LEFT JOIN

  (SELECT
       DATE(parameter_reading_time) reading_date
     , sum(parameter_reading_value) scheduled_downtime
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
         AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)
   GROUP BY DATE(parameter_reading_time)) scheduled_downtime -- 计划检修停机时间
    ON daily_worktime.reading_date = scheduled_downtime.reading_date

  LEFT JOIN

  (SELECT
       DATE(parameter_reading_time) reading_date
     , sum(parameter_reading_value) tech_downtime
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
         AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)
   GROUP BY DATE(parameter_reading_time)) tech_downtime -- 工艺停机时间
    ON daily_worktime.reading_date = tech_downtime.reading_date

  LEFT JOIN

  (SELECT
       DATE(parameter_reading_time) reading_date
     , sum(parameter_reading_value) tech_failure_downtime
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
   WHERE parameter_name = '工艺故障停机时间'
         AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
         AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)
   GROUP BY DATE(parameter_reading_time)) tech_failure_downtime -- 工艺故障停机时间
    ON daily_worktime.reading_date = tech_failure_downtime.reading_date

  LEFT JOIN

  (SELECT
       DATE(parameter_reading_time) reading_date
     , sum(parameter_reading_value) mec_failure_downtime
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
   GROUP BY DATE(parameter_reading_time)) mec_failure_downtime -- 设备机械故障停机时间
    ON daily_worktime.reading_date = mec_failure_downtime.reading_date

  LEFT JOIN

  (SELECT
       DATE(parameter_reading_time) reading_date
     , sum(parameter_reading_value) ele_failure_downtime
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
   WHERE parameter_name = '设备电气故障停机时间'
         AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
         AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)
   GROUP BY DATE(parameter_reading_time)) ele_failure_downtime -- 设备电气故障停机时间
    ON daily_worktime.reading_date = ele_failure_downtime.reading_date


  LEFT JOIN

  (SELECT
       DATE(parameter_reading_time) reading_date
     , sum(parameter_reading_value) automatation_failure_downtime
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
   WHERE parameter_name = '设备自动化故障停机时间'
         AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
         AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)
   GROUP BY DATE(parameter_reading_time)) automatation_failure_downtime -- 设备自动化故障停机时间
    ON daily_worktime.reading_date = automatation_failure_downtime.reading_date;