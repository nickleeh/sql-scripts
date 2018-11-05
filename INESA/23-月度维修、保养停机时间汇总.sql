SELECT date_format(calendar_date, "%y%m")                  AS xkey
#      , scope.location_code                                 AS line_code
     , sum(if(wo_type_type = 'CORR', wo_downtime, 0)) / 60 AS 维修时间
     , sum(if(wo_type_type = 'PREV', wo_downtime, 0)) / 60 AS 保养时间
  FROM
    (SELECT calendar_date
       FROM admin_calendar
    ) AS admin_calendar #       NATURAL JOIN
        #         (SELECT location_code
        #               , location_lft
        #               , location_rgt
        #            FROM asset_location
        #            WHERE location_level = 1
        #         ) AS scope
      LEFT JOIN
        (SELECT wo_id
              , wo_failure_time
              , location_lft
              , wo_downtime
              , wo_type_type
            #                    , wo_start_time
            #                    , wo_finish_time
           FROM wo_history
                  INNER JOIN asset_location ON wo_history.location_code = asset_location.location_code
           WHERE wo_failure_time BETWEEN :start_date AND :end_date
        ) AS wo_history_with_location
        ON admin_calendar.calendar_date = date(wo_history_with_location.wo_failure_time)
#             AND
#            wo_history_with_location.location_lft BETWEEN scope.location_lft AND scope.location_rgt
  WHERE calendar_date BETWEEN :start_date AND :end_date
  GROUP BY date_format(calendar_date, "%y%m") -- , scope.location_code