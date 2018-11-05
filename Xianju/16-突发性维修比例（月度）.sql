SELECT yearmonth                                  AS 月份
     , concat(location_code, location_name)       AS 车间
     , if(CORR = 0, 0, round(TF / CORR * 100, 2)) AS 突发性维修比例
  FROM
    (SELECT date_format(wo_failure_time, "%Y-%m") AS yearmonth
          , factory.location_code
          , factory.location_name
          , sum(IF(wo_type_code = 'TF', 1, 0))    AS TF
          , sum(IF(wo_type_type = 'CORR', 1, 0))  AS CORR
       FROM
         (SELECT location_lft
               , location_rgt
            FROM asset_location
            WHERE location_id = :location_id
         ) AS scope,
         wo_history
           INNER JOIN asset_location ON wo_history.location_code = asset_location.location_code
           INNER JOIN
             (SELECT location_code
                   , location_name
                   , location_lft
                   , location_rgt
                FROM asset_location
                WHERE location_level = 3
             ) AS factory ON asset_location.location_lft BETWEEN factory.location_lft AND factory.location_rgt
       WHERE asset_location.location_lft BETWEEN scope.location_lft AND scope.location_rgt
         AND date(wo_failure_time) BETWEEN :start_date AND :end_date
       GROUP BY date_format(wo_failure_time, "%Y-%m"), factory.location_code
    ) AS CM