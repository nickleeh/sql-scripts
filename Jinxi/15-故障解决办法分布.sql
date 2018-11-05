-- 15-故障解决办法分布
SELECT
    wo_maintenance_activity_name label
  , count(wo_id)                      value
FROM
  (SELECT
     location_lft
     , location_rgt
   FROM asset_location
   WHERE location_id = :location_id) AS T,
  wo_history
  LEFT JOIN asset_location ON wo_history.location_code = asset_location.location_code
WHERE wo_type_type = 'CORR'
      AND wo_failure_time BETWEEN :start_date AND :end_date
      AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
GROUP BY wo_maintenance_activity_name;