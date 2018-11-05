-- Jackie 13 各部门停机时间
SELECT
    concat(asset_location.location_code, ' ', asset_location.location_name) AS xkey
  , sum(wo_downtime) / 3600                                                 AS '工时（小时）'
FROM
  wo_history
  INNER JOIN asset_list ON wo_history.asset_id = asset_list.asset_id
  INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
  INNER JOIN (SELECT
                location_code
                , location_lft
                , location_rgt
              FROM asset_location
              WHERE location_level = 2) AS t
    ON asset_location.location_lft >= t.location_lft AND asset_location.location_rgt <= t.location_rgt
WHERE wo_status = 8
      AND wo_type_type = 'CORR'
      AND wo_creation_time BETWEEN :start_date AND :end_date
GROUP BY t.location_code
ORDER BY sum(wo_downtime) DESC;