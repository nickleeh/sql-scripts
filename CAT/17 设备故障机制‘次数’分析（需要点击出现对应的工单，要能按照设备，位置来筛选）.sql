-- 17 设备故障机制‘次数’分析（需要点击出现对应的工单，要能按照设备，位置来筛选）
SELECT failure_statistics.wo_failure_mechanism_subdivision_code AS 故障编码
     , wo_failure_mechanism_subdivision_name                    AS 故障机制
     , total_wo                                                 AS 工单数
     , no_confirmatioin                                         AS 未评价
     , not_fixed                                                AS 未修复
     , partial_fixed                                            AS 部分修复
     , completely_fixed                                         AS 完全修复
  FROM
    (SELECT wo_failure_mechanism_subdivision_code
          , wo_failure_mechanism_subdivision_name
          , count(wo_id) AS total_wo
       FROM wo_history
              INNER JOIN asset_location ON wo_history.location_code = asset_location.location_code
              INNER JOIN
                (SELECT location_lft
                      , location_rgt
                   FROM asset_location
                   WHERE location_id = :location_id
                ) AS scope
                ON asset_location.location_lft BETWEEN scope.location_lft AND scope.location_rgt
       WHERE wo_type_type = 'CORR'
         AND wo_status = 8
         AND wo_creation_time BETWEEN :start_date AND :end_date
         AND CASE
               WHEN :asset_id = 0 THEN TRUE
               ELSE wo_history.asset_id = :asset_id END
       GROUP BY wo_failure_mechanism_subdivision_code
    ) AS failure_statistics
      INNER JOIN
        (SELECT wo_failure_mechanism_subdivision_code
              , sum(if(wo_confirmation = 0, 1, 0)) AS no_confirmatioin
              , sum(if(wo_confirmation = 1, 1, 0)) AS not_fixed
              , sum(if(wo_confirmation = 2, 1, 0)) AS partial_fixed
              , sum(if(wo_confirmation = 3, 1, 0)) AS completely_fixed
           FROM wo_history
                  INNER JOIN asset_location
                    ON wo_history.location_code = asset_location.location_code
                  INNER JOIN
                    (SELECT location_lft
                          , location_rgt
                       FROM asset_location
                       WHERE location_id = :location_id
                    ) AS scope
                    ON asset_location.location_lft BETWEEN scope.location_lft AND scope.location_rgt
           WHERE wo_type_type = 'CORR'
             AND wo_status = 8
             AND wo_creation_time BETWEEN :start_date AND :end_date
             AND CASE
                   WHEN :asset_id = 0 THEN TRUE
                   ELSE wo_history.asset_id = :asset_id END
           GROUP BY wo_failure_mechanism_subdivision_code
        ) AS confirmation_statistics ON failure_statistics.wo_failure_mechanism_subdivision_code =
                                        confirmation_statistics.wo_failure_mechanism_subdivision_code




-- Part 2
SELECT wo_id      AS 工单号
     , wo_name    AS 工单名称
     , asset_code AS 设备编码
     , asset_name AS 设备名称
  FROM wo_history
  WHERE wo_type_type = ' CORR '
    AND wo_status = 8
    AND wo_creation_time BETWEEN :start_date AND :end_date
    AND wo_type_code = ' CM '
    AND location_code IN
        (SELECT location_code
           FROM asset_location
           WHERE location_lft >=
                 (SELECT location_lft
                    FROM asset_location
                    WHERE location_id = :location_id
                 ) AND location_rgt <=
                       (SELECT location_rgt
                          FROM asset_location
                          WHERE location_id = :location_id
                       )
              OR :location_id = 0
        )
    AND wo_history.asset_id = :asset_id
    AND wo_failure_mechanism_subdivision_code = left(:row, 3)
--
