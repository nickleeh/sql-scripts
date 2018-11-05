SELECT
    @cnt := @cnt + 1       序号
  , asset_code             设备编码
  , asset_name             设备名称
  , location_code          位置编码
  , location_name          位置名称
  , asset_ff_2             位号
  , asset_model            型号
  , asset_serial_number    序列号
  , asset_manufacture_date 生产日期
FROM
  (SELECT @cnt := 0) AS counter,
  (SELECT
     location_lft
     , location_rgt
   FROM asset_location
   WHERE location_id = :location_id) AS T,
  asset_list
  INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
WHERE
  asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
  AND asset_manufacture_date <> '' AND asset_manufacture_date <= curdate() - INTERVAL 10 YEAR