SELECT /* MTBF */
    DATE_FORMAT(wo_creation_time, '%Y-%m')                   AS 日期
     , asset_code                                            AS 机台
     , (DAY(LAST_DAY(wo_creation_time)) * 24) / COUNT(wo_id) AS 平均故障间隔小时
FROM wo_history
WHERE wo_type_type = 'CORR'
  AND wo_status = 8
  AND DATE(wo_creation_time) BETWEEN :start_date AND :end_date
GROUP BY YEAR(wo_creation_time), MONTH(wo_creation_time), asset_code
ORDER BY wo_creation_time ASC