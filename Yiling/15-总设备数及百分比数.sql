SELECT
    loc_code                                       位置编码
  , loc_name                                       位置名称
  , workshop_assets                                设备数量
  , total_assets                                   全厂设备总数
  , round(workshop_assets / total_assets * 100, 2) '百分比%'
FROM
  (SELECT count(asset_code) AS total_assets
   FROM asset_list
   WHERE asset_nature = 0) all_assets,

  (SELECT
       T.location_code   AS loc_code
     , T.location_name   AS loc_name
     , count(asset_code) AS workshop_assets
   FROM
     (SELECT
        location_code
        , location_name
        , location_lft
        , location_rgt
      FROM asset_location
      WHERE location_code IN ('01', '02', '03', '04', '05', '06', '07', '08', '10', '11', '13', '14', 'YP01')) AS T
     LEFT JOIN

     (SELECT
        asset_code
        , location_lft
      FROM
        asset_list
        LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
      WHERE asset_nature = 0) AS assets

       ON assets.location_lft > T.location_lft AND assets.location_lft < T.location_rgt
   GROUP BY t.location_code
  ) AS workshop;