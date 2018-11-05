SELECT *
FROM
  (SELECT
       asset_code                                         设备编码
     , asset_name                                         设备名称
     , asset_category_name                                种类
     , asset_class_name                                   级别
     , location_code                                      位置编码
     , location_name                                      位置名称
     , concat(asset_category_name, "-", asset_class_name) 类别
     , asset_list.asset_ff_1                              设备责任人
     , supplier_name                                      制造商
     , asset_manufacture_date                             生产日期
     , asset_installation_date                            安装日期
     , asset_service_start_date                           起始服务日期
     , asset_warranty_date                                质保期
   FROM
     (SELECT
        location_lft
        , location_rgt
      FROM asset_location
      WHERE location_id = (if(:location_id = 0, 1, :location_id))) AS T,
     asset_list
     JOIN asset_location ON asset_list.location_id = asset_location.location_id
     LEFT JOIN mic_asset_category ON asset_list.asset_category_id = mic_asset_category.asset_category_id
     LEFT JOIN mic_asset_class ON asset_list.asset_class_id = mic_asset_class.asset_class_id
     LEFT JOIN pur_supplier ON asset_list.manufacturer_id = pur_supplier.supplier_id
   WHERE asset_nature = 0 AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
   ORDER BY location_code) body

UNION ALL

(SELECT
   "合计"
   , count(DISTINCT asset_code)
   , NULL
   , NULL
   , NULL
   , NULL
   , NULL
   , NULL
   , NULL
   , NULL
   , NULL
   , NULL
   , NULL
 FROM
   (SELECT
      location_lft
      , location_rgt
    FROM asset_location
    WHERE location_id = (if(:location_id = 0, 1, :location_id))) AS T,
   asset_list
   JOIN asset_location ON asset_list.location_id = asset_location.location_id
 WHERE asset_nature = 0
       AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt)