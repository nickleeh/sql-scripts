SELECT /* MTTR by asset */
    DATE_FORMAT(wo_creation_time, '%Y-%m') AS 日期
     , asset_code                          AS 机台
     , (SUM(TIME_TO_SEC(timediff(wo_finish_time,
                                 IF(wo_failure_time <> '0000-00-00 00:00:00', wo_failure_time, wo_creation_time))) /
            3600) / COUNT(wo_id))          AS '平均修复时间（小时）'
FROM wo_history
WHERE wo_type_type = 'CORR'
  AND wo_status = 8
  AND wo_finish_time <> '0000-00-00 00:00:00'
  AND DATE(wo_creation_time) BETWEEN :start_date AND :end_date
GROUP BY YEAR(wo_creation_time), MONTH(wo_creation_time), asset_code
ORDER BY wo_creation_time ASC