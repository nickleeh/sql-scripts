SELECT asset_class_code                                     AS xkey
     , downtime                                             AS 停机时间
     , round(cumulative_downtime / total_downtime * 100, 2) AS 累积停机百分比
  FROM
    (SELECT asset_class_code
          , downtime
          , @running_total := @running_total + downtime AS cumulative_downtime
       FROM
         (SELECT asset_class_code
               , round(sum(wo_downtime) / 60, 2) AS downtime
            FROM wo_history
#                    INNER JOIN asset_location ON wo_history.location_code = asset_location.location_code
            WHERE wo_type_type = 'CORR'
              AND wo_failure_time BETWEEN :start_date AND :end_date
            GROUP BY asset_class_code
            ORDER BY round(sum(wo_downtime) / 60, 2) DESC
         ) AS down_data
           NATURAL JOIN
             (SELECT @running_total := 0
             ) running_total
    ) downtime_by_class,
    /* Total downtime.*/
    (SELECT round(sum(wo_downtime) / 60, 2) AS total_downtime
       FROM wo_history
       WHERE wo_type_type = 'CORR'
         AND wo_failure_time BETWEEN :start_date AND :end_date
    ) AS total_downtime_data
--
-- Part 2.
SELECT wo_id                      AS 工单号
     , wo_failure_time            AS 故障时间
     , wo_name                    AS 工单名称
     , asset_class_code           AS 机台类型
     , wo_responsible_name        AS 负责人
     , wo_feedback                AS 工单反馈
     , round(wo_downtime / 60, 2) AS '停机时间（分钟）'
  FROM wo_history
  WHERE asset_class_code = :xkey
    AND wo_failure_time BETWEEN :start_date AND :end_date
  ORDER BY wo_downtime DESC