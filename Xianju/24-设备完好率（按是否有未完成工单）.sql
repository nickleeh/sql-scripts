SELECT factory_location_code                                                     AS 编码
     , factory_location_name                                                     AS 车间
     , round(sum(if(asset_condition = 'OK', 1, 0)) / count(asset_code) * 100, 2) AS '完好率%'
  FROM
    (SELECT factory.location_code AS factory_location_code
          , factory.location_name AS factory_location_name
          , asset_code
          , IF(sum(IF(type_code <> 'LX' AND type_code IS NOT NULL AND wo_status < 6, 1, 0)) > 0,
               'NG', 'OK')        AS asset_condition
       FROM
         (SELECT location_code
               , location_lft
               , location_rgt
            FROM asset_location
            WHERE location_id = IF(:location_id = 0, 1, :location_id)
         ) AS scope,
         asset_list
           LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
           LEFT JOIN wo_list ON asset_list.asset_id = wo_list.wo_asset_id
           LEFT JOIN mic_type ON wo_list.wo_type_id = mic_type.type_id
           LEFT JOIN
             (SELECT location_code
                   , location_name
                   , location_lft
                   , location_rgt
                FROM asset_location
                WHERE location_level = 3
                  AND location_code <> 'A08'
             ) AS factory
             ON asset_location.location_lft BETWEEN factory.location_lft AND factory.location_rgt
       WHERE asset_location.location_lft BETWEEN scope.location_lft AND scope.location_rgt
       GROUP BY asset_list.asset_code
    ) AS asset_condition_list
  WHERE factory_location_code <> ''
  GROUP BY factory_location_code