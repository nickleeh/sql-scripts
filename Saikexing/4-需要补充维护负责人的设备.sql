SELECT
    asset_code     设备编码
  , asset_name     设备名称
  , responsible_id 维护负责人
FROM
  (SELECT
     location_lft
     , location_rgt
   FROM asset_location
   WHERE location_id = :location_id) AS T,
  asset_list
  JOIN asset_location ON asset_list.location_id = asset_location.location_id
WHERE asset_nature = 0 AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
      AND asset_responsible_id = ''