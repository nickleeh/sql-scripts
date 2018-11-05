SELECT number_of_failure_assets                                                           AS 故障设备数
     , number_of_assets                                                                   AS 总设备数
     , round(((number_of_assets - number_of_failure_assets) / number_of_assets) * 100, 2) AS 设备完好率
  FROM
    (SELECT count(asset_code) AS number_of_failure_assets
       FROM
         (SELECT location_lft
               , location_rgt
            FROM asset_location
            WHERE location_id = if(:location_id = 0, 1, :location_id)
         ) AS scope1,
         wo_history
           INNER JOIN asset_location ON wo_history.location_code = asset_location.location_code
       WHERE wo_type_type = 'CORR'
         AND wo_failure_time BETWEEN :start_date AND :end_date
         AND wo_finish_time >= date_add(wo_target_time, INTERVAL +2 DAY)
         AND asset_location.location_lft BETWEEN scope1.location_lft AND scope1.location_rgt
    ) AS failure_assets,
    (SELECT count(asset_code) AS number_of_assets
       FROM
         (SELECT location_lft
               , location_rgt
            FROM asset_location
            WHERE location_id = if(:location_id = 0, 1, :location_id)
         ) AS scope2,
         asset_list
           INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
       WHERE asset_location.location_lft BETWEEN scope2.location_lft AND scope2.location_rgt
    ) AS all_assets