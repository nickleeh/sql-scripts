SELECT
  -- 实际作业率 = (总工作时间-总停机时间) / 总工作时间
  daily_worktime.reading_date
  , round(
        (daily_worktime - daily_downtime) / daily_worktime *
        100,
        2) '实际作业率'
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
   WHERE parameter_name = '总工作时间'
         AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
         AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)
   GROUP BY date(parameter_reading_time)) daily_worktime

  JOIN

  (SELECT
       date(parameter_reading_time) reading_date
     , sum(parameter_reading_value) daily_downtime
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
         AND parameter_reading_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)
   GROUP BY date(parameter_reading_time)) daily_downtime
    ON daily_worktime.reading_date = daily_downtime.reading_date