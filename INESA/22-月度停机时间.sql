SELECT yearmonth                                     AS xkey
     , sum(if(line_code = 'BL1', line_downtime, 0))  AS BL1
     , sum(if(line_code = 'BL2', line_downtime, 0))  AS BL2
     , sum(if(line_code = 'BM1', line_downtime, 0))  AS BM1
     , sum(if(line_code = 'BM2', line_downtime, 0))  AS BM2
     , sum(if(line_code = 'CR1', line_downtime, 0))  AS CR1
     , sum(if(line_code = 'CR2', line_downtime, 0))  AS CR2
     , sum(if(line_code = 'GR1', line_downtime, 0))  AS GR1
     , sum(if(line_code = 'GR2', line_downtime, 0))  AS GR2
     , sum(if(line_code = 'IN1', line_downtime, 0))  AS IN1
     , sum(if(line_code = 'IN2', line_downtime, 0))  AS IN2
     , sum(if(line_code = 'LR1', line_downtime, 0))  AS LR1
     , sum(if(line_code = 'MA1', line_downtime, 0))  AS MA1
     , sum(if(line_code = 'MA2', line_downtime, 0))  AS MA2
     , sum(if(line_code = 'MSK1', line_downtime, 0)) AS MSK1
     , sum(if(line_code = 'OQC', line_downtime, 0))  AS OQC
     , sum(if(line_code = 'OTH1', line_downtime, 0)) AS OTH1
     , sum(if(line_code = 'OTH2', line_downtime, 0)) AS OTH2
     , sum(if(line_code = 'OTH3', line_downtime, 0)) AS OTH3
     , sum(if(line_code = 'PAK', line_downtime, 0))  AS PAK
     , sum(if(line_code = 'PS1', line_downtime, 0))  AS PS1
     , sum(if(line_code = 'PS2', line_downtime, 0))  AS PS2
     , sum(if(line_code = 'RE1', line_downtime, 0))  AS RE1
     , sum(if(line_code = 'RE2', line_downtime, 0))  AS RE2
     , sum(if(line_code = 'REW', line_downtime, 0))  AS REW
     , sum(if(line_code = 'STK', line_downtime, 0))  AS STK
     , sum(if(line_code = 'TR1', line_downtime, 0))  AS TR1
     , sum(if(line_code = 'TR2', line_downtime, 0))  AS TR2
     , sum(if(line_code = 'TR3', line_downtime, 0))  AS TR3
     , sum(if(line_code = 'TR4', line_downtime, 0))  AS TR4
     , sum(if(line_code = 'UPK', line_downtime, 0))  AS UPK
  FROM
    (SELECT date_format(calendar_date, "%y%m") AS yearmonth
          , scope.location_code                AS line_code
          , sum(wo_downtime) / 60              AS line_downtime
       FROM
         (SELECT calendar_date
            FROM admin_calendar
         ) AS admin_calendar
           NATURAL JOIN
             (SELECT location_code
                   , location_lft
                   , location_rgt
                FROM asset_location
                WHERE location_level = 1
             ) AS scope
           LEFT JOIN
             (SELECT wo_id
                   , wo_failure_time
                   , location_lft
                   , wo_downtime
                FROM wo_history
                       INNER JOIN asset_location ON wo_history.location_code = asset_location.location_code
                WHERE wo_failure_time BETWEEN :start_date AND :end_date
                  AND wo_type_type = 'CORR'
             ) AS wo_history_with_location
             ON admin_calendar.calendar_date = date(wo_history_with_location.wo_failure_time) AND
                wo_history_with_location.location_lft BETWEEN scope.location_lft AND scope.location_rgt
       WHERE calendar_date BETWEEN :start_date AND :end_date
       GROUP BY date_format(calendar_date, "%y%m"), scope.location_code
    ) AS grouped_downtime
  GROUP BY yearmonth