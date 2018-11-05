SELECT
    location_code                                                         车间号
  , workshops.location_name                                               车间名称
  , employee_name                                                         维护负责人
  , sum(running_time)                                                     月度运行时间
  , sum(down_time)                                                        月度停机时间
  , round(sum(down_time) / (sum(down_time) + sum(running_time)) * 100, 2) 月度停机率
FROM

  (SELECT
     running_data.asset_id
     , running_data.yearmonth
     , running_time
     , down_time
     , running_data.location_lft
   FROM
     (SELECT
          asset_list.asset_id                                             AS asset_id
        , extract(YEAR_MONTH FROM parameter_reading_time)                 AS yearmonth
        , sum(parameter_reading_value) /* Pierre think the unit is hour*/ AS running_time
        , location_lft
      FROM asset_parameter_reading
        LEFT JOIN asset_parameter ON asset_parameter_reading.parameter_id = asset_parameter.parameter_id
        LEFT JOIN asset_list ON asset_parameter.asset_id = asset_list.asset_id
        LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
      GROUP BY extract(YEAR_MONTH FROM parameter_reading_time)
     ) AS running_data

     LEFT JOIN

     (SELECT
        wo_history.asset_id
        , extract(YEAR_MONTH FROM wo_creation_time)      AS yearmonth
        , sum(wo_downtime / 3600) /* convert to hours */ AS down_time
        , location_lft
      FROM wo_history
        LEFT JOIN asset_location ON wo_history.location_code = asset_location.location_code
      GROUP BY extract(YEAR_MONTH FROM wo_creation_time)
     ) AS down_data

       ON running_data.asset_id = down_data.asset_id
   --  ^left_join_data

   UNION ALL

   SELECT
     down_data.asset_id
     , down_data.yearmonth
     , running_time
     , down_data.down_time
     , down_data.location_lft
   FROM
     (SELECT
          asset_list.asset_id                                             AS asset_id
        , extract(YEAR_MONTH FROM parameter_reading_time)                 AS yearmonth
        , sum(parameter_reading_value) /* Pierre think the unit is hour*/ AS running_time
        , location_lft
      FROM asset_parameter_reading
        LEFT JOIN asset_parameter ON asset_parameter_reading.parameter_id = asset_parameter.parameter_id
        LEFT JOIN asset_list ON asset_parameter.asset_id = asset_list.asset_id
        LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
      GROUP BY extract(YEAR_MONTH FROM parameter_reading_time)
     ) AS running_data

     RIGHT JOIN

     (SELECT
        wo_history.asset_id
        , extract(YEAR_MONTH FROM wo_creation_time)      AS yearmonth
        , sum(wo_downtime / 3600) /* convert to hours */ AS down_time
        , location_lft
      FROM wo_history
        LEFT JOIN asset_location ON wo_history.location_code = asset_location.location_code
      GROUP BY extract(YEAR_MONTH FROM wo_creation_time)
     ) AS down_data

       ON running_data.asset_id = down_data.asset_id
    --  ^right_join_data

  ) AS running_and_downtime

  RIGHT JOIN

  (SELECT
     location_code
     , location_name
     , location_lft
     , location_rgt
     , employee_name
   FROM asset_location
     INNER JOIN admin_employee ON asset_location.responsible_id = admin_employee.employee_id
   WHERE
     location_code IN ('01', '02', '03', '04', '05', '06', '07', '08', '10', '11', '13', '14', 'YP01')) AS workshops
    ON running_and_downtime.location_lft > workshops.location_lft AND
       running_and_downtime.location_lft < workshops.location_rgt

GROUP BY location_code
ORDER BY location_code