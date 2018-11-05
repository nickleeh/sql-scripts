-- Part 1.
SELECT
    date(wo_failure_time) xkey
  , count(wo_id)          '故障数'
FROM (SELECT
        location_lft
        , location_rgt
      FROM asset_location
      WHERE location_id = if(:location_id = 0, 1, :location_id)) AS T,
  wo_history
  LEFT JOIN asset_list ON wo_history.asset_code = asset_list.asset_code
  LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
WHERE wo_type_type = 'CORR'
      AND asset_location.location_lft BETWEEN t.location_lft AND t.location_rgt
      AND wo_failure_time BETWEEN :start_date AND :end_date
GROUP BY date(wo_failure_time);

-- Part 2.
SELECT
    asset_name   设备名称
  , count(wo_id) 故障次数
FROM wo_history
WHERE wo_type_type = 'CORR' AND date(wo_failure_time) = :label
GROUP BY date(wo_creation_time), asset_code;