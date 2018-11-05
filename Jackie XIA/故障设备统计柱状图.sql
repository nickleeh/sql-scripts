SELECT
    wo_history.asset_name AS xkey
  , count(wo_id)          AS 故障次数
FROM
  (SELECT
     location_lft
     , location_rgt
   FROM asset_location
   WHERE location_id = if(:location_id = 0, 1, :location_id)) AS T,
  wo_history
  INNER JOIN mic_status ON status_id = wo_Status
  INNER JOIN asset_list ON asset_list.asset_id = wo_history.asset_id
  INNER JOIN asset_location ON asset_location.location_id = asset_list.location_id
WHERE wo_type_type = 'CORR'
      AND wo_status = '8'
      AND asset_level = 1
      AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
      AND date(wo_failure_time) BETWEEN :start_date AND :end_date
GROUP BY wo_history.asset_code
ORDER BY count(wo_id) DESC;
