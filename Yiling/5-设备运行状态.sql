-- First part.
SELECT
    t.location_code                              位置编码
  , t.location_name                              位置名称
  , concat(asset_status, " ", asset_status_name) '状态'
  , COUNT(asset_code)                            '数量'

FROM
  (SELECT
     location_code
     , location_name
     , location_lft
     , location_rgt
   FROM asset_location
   WHERE location_id = if(:location_id = 0, 1, :location_id)) AS T,
  asset_list
  JOIN asset_location ON asset_list.location_id = asset_location.location_id
  LEFT JOIN mic_asset_status ON asset_list.asset_status = mic_asset_status.asset_status_id
WHERE asset_nature = 0 AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
GROUP BY asset_status;
--

-- Second part.
SELECT
    @cnt := @cnt + 1                                      序号
  , asset_code                                            设备编码
  , asset_name                                            设备名称
  , location_code                                         位置编码
  , location_name                                         位置名称
  , concat(asset_category_code, " ", asset_category_name) 大类
  , concat(asset_class_code, " ", asset_class_name)       中类
  , concat(asset_status, " ", asset_status_name)          '设备状态'
FROM
  (SELECT @cnt := 0) counter,
  (SELECT
     location_lft
     , location_rgt
   FROM asset_location
   WHERE location_id = if(:location_id = 0, 1, :location_id)) AS T,
  asset_list
  JOIN asset_location ON asset_list.location_id = asset_location.location_id
  LEFT JOIN mic_asset_category ON asset_list.asset_category_id = mic_asset_category.asset_category_id
  LEFT JOIN mic_asset_class ON asset_list.asset_class_id = mic_asset_class.asset_class_id
  LEFT JOIN mic_asset_status ON asset_list.asset_status = mic_asset_status.asset_status_id
WHERE asset_nature = 0 AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
      AND left(:cell, 1) = asset_status;
