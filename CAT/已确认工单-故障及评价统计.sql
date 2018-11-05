SELECT failure_statistics.wo_failure_mechanism_subdivision_id AS 故障编码
     , failure_statistics.failure_mechanism_subdivision_name  AS 故障机制
     , no_confirmatioin                                       AS 未评价
     , not_fixed                                              AS 未修复
     , partial_fixed                                          AS 部分修复
     , completely_fixed                                       AS 完全修复
     , total_wo                                               AS 总数
  FROM
    (SELECT wo_failure_mechanism_subdivision_id
          , failure_mechanism_subdivision_name
          , count(wo_id) AS total_wo
       FROM wo_list
              INNER JOIN asset_list ON wo_list.wo_asset_id = asset_list.asset_id
              INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
              LEFT JOIN mic_failure_mechanism_subdivision
                ON wo_list.wo_failure_mechanism_subdivision_id =
                   mic_failure_mechanism_subdivision.failure_mechanism_subdivision_id
              INNER JOIN
                (SELECT location_lft
                      , location_rgt
                   FROM asset_location
                   WHERE location_id = :location_id
                ) AS scope
                ON asset_location.location_lft BETWEEN scope.location_lft AND scope.location_rgt
       WHERE wo_type_id = 1
         AND wo_status = 7
         AND wo_creation_time BETWEEN :start_date AND :end_date
         AND CASE
               WHEN :asset_id = 0 THEN TRUE
               ELSE wo_list.wo_asset_id = :asset_id END
       GROUP BY wo_failure_mechanism_subdivision_id
    ) AS failure_statistics
      INNER JOIN
        (SELECT wo_failure_mechanism_subdivision_id
              , sum(if(wo_confirmation = 0, 1, 0)) AS no_confirmatioin
              , sum(if(wo_confirmation = 1, 1, 0)) AS not_fixed
              , sum(if(wo_confirmation = 2, 1, 0)) AS partial_fixed
              , sum(if(wo_confirmation = 3, 1, 0)) AS completely_fixed
           FROM wo_list
                  INNER JOIN asset_list ON wo_list.wo_asset_id = asset_list.asset_id
                  INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
                  LEFT JOIN mic_failure_mechanism_subdivision
                    ON wo_list.wo_failure_mechanism_subdivision_id =
                       mic_failure_mechanism_subdivision.failure_mechanism_subdivision_id
                  INNER JOIN
                    (SELECT location_lft
                          , location_rgt
                       FROM asset_location
                       WHERE location_id = :location_id
                    ) AS scope
                    ON asset_location.location_lft BETWEEN scope.location_lft AND scope.location_rgt
           WHERE wo_type_id = 1
             AND wo_status = 7
             AND wo_creation_time BETWEEN :start_date AND :end_date
             AND CASE
                   WHEN :asset_id = 0 THEN TRUE
                   ELSE wo_list.wo_asset_id = :asset_id END
           GROUP BY wo_failure_mechanism_subdivision_id
        ) AS confirmation_statistics ON failure_statistics.wo_failure_mechanism_subdivision_id =
                                        confirmation_statistics.wo_failure_mechanism_subdivision_id