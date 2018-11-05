SELECT date_format(calendar_date, "%Y-%m") AS 日期
     , scope.location_code                 AS 线体
     , sum(wo_ff_1)                        AS 破片
     , sum(wo_ff_2)                        AS 报废
  FROM
    (SELECT calendar_date
       FROM admin_calendar
    ) AS admin_calendar
      NATURAL JOIN
        (SELECT /* Production lines. */
             location_code
              , location_lft
              , location_rgt
           FROM asset_location
           WHERE location_level = 1
        ) AS scope
      LEFT JOIN
        (SELECT /* Work orders with asset location*/
             wo_history.wo_id
              , wo_failure_time
              , location_lft
              , wo_type_type
              , wo_ff_1
              , wo_ff_2
           FROM wo_history
                  LEFT JOIN wo_freefield ON wo_history.wo_id = wo_freefield.wo_id
                  INNER JOIN asset_location ON wo_history.location_code = asset_location.location_code
        ) AS wo_history_with_location
        ON wo_history_with_location.location_lft BETWEEN scope.location_lft AND scope.location_rgt AND
           date(wo_history_with_location.wo_failure_time) = admin_calendar.calendar_date
  WHERE admin_calendar.calendar_date BETWEEN :start_date AND :end_date
    AND (wo_type_type = 'CORR' OR wo_type_type IS NULL)
  GROUP BY date_format(calendar_date, "%Y-%m"), scope.location_code
--
-- Part 2.
SELECT /* Work orders with asset location*/
    wo_history.wo_id   AS 工单号
     , wo_name         AS 工单名称
     , wo_failure_time AS 故障时间
     , wo_ff_1         AS 破片
     , wo_ff_2         AS 报废
  FROM wo_history
         LEFT JOIN wo_freefield ON wo_history.wo_id = wo_freefield.wo_id
         INNER JOIN asset_location ON wo_history.location_code = asset_location.location_code
  WHERE date_format(wo_failure_time, "%Y-%m") = :row
    AND wo_type_type = 'CORR'
    AND (wo_ff_1 <> 0 OR wo_ff_2 <> 0)