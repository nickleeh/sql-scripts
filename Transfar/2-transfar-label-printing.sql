SELECT
  asset_code  设备编码,
  asset_name  设备名称,
  asset_model 规格型号
FROM
  (SELECT
     location_lft,
     location_rgt
   FROM asset_location
   WHERE location_id = :location_id) AS T,
  asset_list
  LEFT JOIN asset_location aloc ON asset_list.location_id = aloc.location_id
WHERE asset_nature = 0
      AND aloc.location_lft BETWEEN t.location_lft AND t.location_rgt
      AND asset_level = 1 -- Only print label for first level assets;