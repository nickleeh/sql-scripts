SELECT failure_mecanism                                       AS xkey
     , failure_qty                                            AS 数量
     , round(cumulative_failure / total_failure_qty * 100, 2) AS '百分比%'
  FROM
    (SELECT concat(wo_failure_mechanism_subdivision_code, " ",
                   wo_failure_mechanism_subdivision_name)  AS failure_mecanism
          , failure_qty
          , @running_total := @running_total + failure_qty AS cumulative_failure
          , total_failure.total_failure_qty
       FROM
         (SELECT wo_failure_mechanism_subdivision_code
               , wo_failure_mechanism_subdivision_name
               , COUNT(wo_id) AS failure_qty
            FROM wo_history
            WHERE wo_type_type = 'CORR'
              AND DATE(wo_failure_time) BETWEEN :start_date AND :end_date
              AND asset_class_code = :asset_class_code
            GROUP BY wo_failure_mechanism_subdivision_code
            ORDER BY COUNT(wo_id) DESC
         ) AS failure_data
           NATURAL JOIN
             (SELECT @running_total := 0
             ) running_total,
         (SELECT COUNT(wo_id) AS total_failure_qty
            FROM wo_history
            WHERE wo_type_type = 'CORR'
              AND DATE(wo_failure_time) BETWEEN :start_date AND :end_date
              AND asset_class_code = :asset_class_code
            ORDER BY COUNT(wo_id) DESC
         ) AS total_failure
    ) AS total_failure_data
--

SELECT wo_id               AS 工单号
     , wo_name             AS 工单名称
     , asset_code          AS 设备编码
     , asset_name          AS 设备名称
     , wo_responsible_name AS 负责人
     , wo_failure_time     AS 故障时间
     , wo_finish_time      AS 完成时间
  FROM wo_history
  WHERE wo_type_type = 'CORR'
    AND DATE(wo_failure_time) BETWEEN :start_date AND :end_date
    AND asset_class_code = :asset_class_code
    AND wo_failure_mechanism_subdivision_code = substring_index(:xkey, " ", 1)