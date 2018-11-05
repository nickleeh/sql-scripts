SELECT
    T.location_code 编码
  , T.location_name 牧场
  , count(mr_id)    报修数
FROM
  mr_list
  INNER JOIN asset_list ON mr_list.mr_asset_id = asset_list.asset_id
  INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
  RIGHT JOIN
  (SELECT
     location_code
     , location_name
     , location_lft
     , location_rgt
   FROM asset_location
   WHERE location_code IN
         ('10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '21', '22', '23', '32', '34', '3403')) AS T
    ON asset_location.location_lft > T.location_lft AND asset_location.location_lft < T.location_rgt
-- where mr_failure_time between :start_date and :end_date
GROUP BY T.location_lft
ORDER BY count(mr_id) DESC