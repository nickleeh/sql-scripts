SELECT asset_code    AS 设备编码
     , asset_name    AS 设备名称
     , location_code AS 位置编码
     , location_name AS 位置名称
FROM
  (SELECT location_lft, location_rgt FROM asset_location WHERE location_code = 'JIT') AS scope,
  asset_list
    INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
WHERE asset_nature = 0
  AND asset_location.location_lft BETWEEN scope.location_lft AND scope.location_rgt
;