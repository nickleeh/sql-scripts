-- 五亭桥设备完好率
SELECT
  year(wo_failure_time)                               年,
  month(wo_failure_time)                              月,
  round((count(DISTINCT asset_list.asset_id) - count(DISTINCT mr_id)) /
        count(DISTINCT asset_list.asset_id) * 100, 2) 完好率
FROM

  ((SELECT
      wo_id,
      mr_id,
      wo_failure_time,
      wo_finish_time,
      location_lft
    FROM
      wo_history
      LEFT JOIN asset_location l1 ON wo_history.asset_id = l1.location_asset_id
    WHERE wo_finish_time > TIMESTAMP(LAST_DAY(wo_failure_time), '23:59:59'))

   UNION

   (SELECT
      wo_id,
      mr_id,
      wo_failure_time,
      wo_finish_time,
      location_lft
    FROM
      wo_list
      LEFT JOIN asset_location l2 ON wo_list.wo_asset_id = l2.location_asset_id
    WHERE wo_status < 6)) failed
  ,

  asset_list
  LEFT JOIN asset_location l0 ON asset_list.asset_id = l0.location_asset_id
  ,

  (SELECT
     location_lft,
     location_rgt
   FROM asset_location
   WHERE location_id = :location_id) AS loc

WHERE
  failed.location_lft BETWEEN loc.location_lft AND loc.location_rgt
  AND l0.location_lft BETWEEN loc.location_lft AND loc.location_rgt
  AND wo_failure_time > '2017-05-01'
GROUP BY YEAR(wo_failure_time), MONTH(wo_failure_time)