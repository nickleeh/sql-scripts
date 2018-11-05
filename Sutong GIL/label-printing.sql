USE hh6;

SELECT
  location_code 位置编码,
  location_name 位置名称,
  asset_code    设备编码,
  asset_name    设备名称
FROM

  (SELECT
     location_lft,
     location_rgt
   FROM asset_location
   WHERE location_id = :location_id) AS loc,

  asset_list
  JOIN asset_location ON asset_list.location_id = asset_location.location_id

WHERE asset_nature = 0
      AND asset_level = 1 -- Only print label for first level assets.
      AND asset_status = 1 -- assets in use.
      AND asset_location.location_lft BETWEEN loc.location_lft AND loc.location_rgt
ORDER BY location_code