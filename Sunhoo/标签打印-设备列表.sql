USE hh7;
SELECT
  asset_code             设备编码,
  asset_name             设备名称,
  asset_model            型号,
  location_name          使用部门,
  asset_manufacture_date 生产日期,
  supplier_name          制造厂家,
  criticality_code       `关键性（标识）`
FROM
  (SELECT
     location_lft,
     location_rgt
   FROM asset_location
   WHERE location_id = :location_id) AS T,
  asset_list
  JOIN asset_location ON asset_list.location_id = asset_location.location_id
  LEFT JOIN pur_supplier ON manufacturer_id = pur_supplier.supplier_id
  LEFT JOIN mic_criticality ON asset_list.criticality_id = mic_criticality.criticality_id
WHERE asset_nature = 0 AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
