SELECT
    assets.asset_code            '编码'
  , assets.asset_name            '名称'
  , workshop_code                '车间编号'
  , asset_location.location_name '车间名称'
  , assets.floor                 '楼层'
  , assets.location_code         '房间编码'
  , assets.location_name         '房间名称'
  , assets.asset_model           '型号'
  , assets.supplier_name         '制造商'
FROM
  (SELECT
     asset_code
     , asset_name
     , location_name
     , location_code
     , CASE
       WHEN location_code LIKE 'FP%' THEN '08' -- 08 提取二车间
       WHEN location_code LIKE 'YP%' THEN 'YP01' -- YP01 饮片车间
       WHEN location_code LIKE 'F%' THEN '07' -- 07 质量控制部
       WHEN location_code LIKE 'P%' THEN right(left(location_code, 3), 2) -- 普通车间
       ELSE left(location_code, 2) -- 位置在普通车间楼层的，取前两位即车间编号。
       END AS workshop_code
     , CASE
       WHEN location_code LIKE 'FP%' THEN substring(location_code, 5, 1) -- 08 提取二车间
       WHEN location_code LIKE 'YP%' THEN substring(location_code, 5, 1) -- YP01 饮片车间
       WHEN location_code LIKE 'F%' THEN substring(location_code, 2, 2) -- 07 质量控制部
       WHEN location_code LIKE 'P%' THEN substring(location_code, 4, 1) -- 普通车间
       ELSE substring(location_code, 3, 2) -- 位置在普通车间楼层的，取3-4位即车间编号。
       END AS floor
     , asset_model
     , supplier_name
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
         AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt) assets
  LEFT JOIN asset_location ON assets.workshop_code = asset_location.location_code
ORDER BY assets.location_code;