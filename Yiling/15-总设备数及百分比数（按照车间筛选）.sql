SELECT
    T.location_code                                位置编码
  , T.location_name                                位置名称
  , count(asset_id)                                设备数量
  , total_assets                                   全厂设备总数
  , round(count(asset_id) / total_assets * 100, 2) '百分比%'
FROM
  (SELECT count(asset_code) AS total_assets
   FROM asset_list
   WHERE asset_nature = 0) all_assets,
  (SELECT
     location_code
     , location_name
     , location_lft
     , location_rgt
   FROM asset_location
   WHERE location_id = if(:location_id = 0, 1, :location_id)) AS T,
  asset_list
  LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
WHERE asset_nature = 0
      AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt;