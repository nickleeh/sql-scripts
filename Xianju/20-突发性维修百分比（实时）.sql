SELECT factory_location_code     AS 编码
     , factory_location_name     AS 车间
    /* wo_type 'TF' percentage among corrective maintenance. */
     , round(TF / CORR * 100, 2) AS '突发性维修百分比（实时）'
  FROM
    (SELECT factory_location_code
          , factory_location_name
          , sum(IF(type_code = 'TF', 1, 0))   AS TF
          , sum(IF(type_type = 'CORR', 1, 0)) AS CORR
       FROM
         (-- /* All current work order. */
           SELECT factory.location_code       AS factory_location_code
                , factory.location_name       AS factory_location_name
                , wo_id
                , wo_creation_time
                , type_code
                , type_type
                , asset_location.location_lft AS location_left
             FROM wo_list
                    INNER JOIN mic_type ON wo_list.wo_type_id = mic_type.type_id
                    INNER JOIN asset_list ON wo_list.wo_asset_id = asset_list.asset_id
                    INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
                    INNER JOIN
                      (SELECT location_code
                            , location_name
                            , location_lft
                            , location_rgt
                         FROM asset_location
                         WHERE location_level = 3
                      ) AS factory
                      ON asset_location.location_lft BETWEEN factory.location_lft AND factory.location_rgt

           UNION ALL

           --  history work order
           SELECT factory.location_code AS factory_location_code
                , factory.location_name AS factory_location_name
                , wo_id
                , wo_creation_time
                , wo_type_code
                , wo_type_type
                , asset_location.location_lft
             FROM wo_history
                    INNER JOIN asset_location
                      ON wo_history.location_code = asset_location.location_code
                    INNER JOIN
                      (SELECT location_code
                            , location_name
                            , location_lft
                            , location_rgt
                         FROM asset_location
                         WHERE location_level = 3
                      ) AS factory
                      ON asset_location.location_lft BETWEEN factory.location_lft AND factory.location_rgt
         ) all_work_order,
         /* Scope. */
         (SELECT location_lft
               , location_rgt
            FROM asset_location
            WHERE location_id = :location_id
         ) AS scope
       WHERE all_work_order.location_left BETWEEN scope.location_lft AND scope.location_rgt
         AND wo_creation_time BETWEEN :start_date AND :end_date
       GROUP BY factory_location_code
    ) AS CM