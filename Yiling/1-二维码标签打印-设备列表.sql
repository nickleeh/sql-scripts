SELECT
    asset_code                                            设备编码
  , asset_name                                            设备名称
  , location_code                                         位置编码
  , location_name                                         位置名称
  , concat(asset_category_code, " ", asset_category_name) 大类
  , concat(asset_class_code, " ", asset_class_name)       中类
FROM
  (SELECT
     location_lft
     , location_rgt
   FROM asset_location
   WHERE location_id = :location_id) AS T,
  asset_list
  JOIN asset_location ON asset_list.location_id = asset_location.location_id
  LEFT JOIN mic_asset_category ON asset_list.asset_category_id = mic_asset_category.asset_category_id
  LEFT JOIN mic_asset_class ON asset_list.asset_class_id = mic_asset_class.asset_class_id
WHERE asset_nature = 0 AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt;