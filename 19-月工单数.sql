SELECT report_month AS xkey
     , count(wo_id) AS 工单数
FROM
  (SELECT location_lft
        , location_rgt
   FROM asset_location
   WHERE location_id = :location_id) AS scope,
  (SELECT calendar_date
        , if(day(calendar_date) <= 20, date_format(calendar_date, '%Y-%m'),
             date_format(calendar_date + INTERVAL 1 MONTH, '%Y-%m')) AS report_month
   FROM admin_calendar) AS report_calendar
    INNER JOIN (SELECT wo_id
                     , wo_creation_time
                     , location_lft
                FROM wo_list
                       INNER JOIN asset_list ON wo_list.wo_asset_id = asset_list.asset_id
                       INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id

                UNION

                SELECT wo_id
                     , wo_creation_time
                     , location_lft
                FROM wo_history
                       INNER JOIN asset_location ON wo_history.location_code = asset_location.location_code) AS wo_all
      ON report_calendar.calendar_date = date(wo_all.wo_creation_time)
WHERE wo_all.location_lft BETWEEN scope.location_lft AND scope.location_rgt
GROUP BY report_calendar.report_month
;