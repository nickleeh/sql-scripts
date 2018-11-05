SELECT
  `Year-Month`
  , scope_loc_code                                                                        AS 'Plant'
  ,
    `Total preventive maintenance (Min)`                                                  AS 'Preventive Maintenance (Min)'
  ,
    `Total corrective maintenance (Min)`                                                  AS 'Corrective Maintenance (Min)'
  , round(`Total preventive maintenance (Min)` / `Total corrective maintenance (Min)`, 2) AS 'KPI 4'

FROM
  (SELECT
     scope_loc_code
     , date_format(wo_creation_time, "%Y-%m") AS 'Year-Month'
     , @total_pm := round(
        sum(IF(wo_type_type = 'PREV', IF(wo_worked_hour <> 0, wo_worked_hour * 60,
                                         timediff(
                                             IF(wo_finish_time <> 0, wo_finish_time, wo_archive_time),
                                             wo_start_time) /
                                         60), 0)),
        2)                                    AS 'Total preventive maintenance (Min)'
     , @total_cm := round(
        sum(IF(wo_type_type = 'CORR',
               IF(wo_worked_hour <> 0, wo_worked_hour * 60,
                  timediff(IF(wo_finish_time <> 0, wo_finish_time, wo_archive_time), wo_start_time) /
                  60),
               0)),
        2)                                    AS 'Total corrective maintenance (Min)'
   FROM wo_history
     INNER JOIN wo_history_employee ON wo_history.wo_id = wo_history_employee.wo_id
     INNER JOIN asset_location ON wo_history.location_code = asset_location.location_code
     INNER JOIN
     (SELECT
        location_code AS scope_loc_code
        , location_lft
        , location_rgt
      FROM asset_location
      WHERE location_code IN ('FAN', 'FCA')) AS scope
       ON asset_location.location_lft > scope.location_lft AND asset_location.location_rgt < scope.location_rgt
   GROUP BY scope.scope_loc_code, date_format(wo_creation_time, "%Y-%m")) AS all_data
ORDER BY `Year-Month`, scope_loc_code