SELECT
    asset_code             '编码'
  , asset_name             '名称'
  --  , asset_model   '型号'
  , supplier_name          '制造商'
  , location_name          '房间名称'
  , asset_alternative_code '固定资产编码'
FROM
  (SELECT
     location_lft
     , location_rgt
   FROM asset_location
   WHERE location_id = :location_id) AS T,
  asset_list
  LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
  LEFT JOIN pur_supplier ON asset_list.manufacturer_id = pur_supplier.supplier_id
WHERE asset_nature = 0
      AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt;