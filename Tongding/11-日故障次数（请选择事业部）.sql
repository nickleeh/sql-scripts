SELECT scope.location_name   AS 事业部
     , date(wo_failure_time) AS 日期
     , count(wo_id)          AS 故障次数
  FROM
    (SELECT location_code
          , location_name
          , location_lft
          , location_rgt
       FROM asset_location
       WHERE location_id = :location_id
    ) AS scope,
    (SELECT wo_id
          , wo_failure_time
          , location_lft
          , type_code
       FROM wo_list
              INNER JOIN asset_list ON wo_list.wo_asset_id = asset_list.asset_id
              INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
              INNER JOIN mic_type ON wo_list.wo_type_id = mic_type.type_id

     UNION

     SELECT wo_id
          , wo_failure_time
          , location_lft
          , wo_type_code
       FROM wo_history
              INNER JOIN asset_location ON wo_history.location_code = asset_location.location_code
    ) AS wo_all

  WHERE wo_all.location_lft BETWEEN scope.location_lft AND scope.location_rgt
    AND type_code = 'CM'
    AND wo_failure_time BETWEEN :start_date AND :end_date
  GROUP BY scope.location_code, date(wo_failure_time)
  ORDER BY date(wo_failure_time) DESC