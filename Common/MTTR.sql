SELECT
  DATE_FORMAT(wo_creation_time, '%Y-%m') AS xkey,
  (SUM(if(wo_downtime <> 0, wo_downtime,
          TIME_TO_SEC(timediff(wo_finish_time,
                               IF(wo_failure_time <> '0000-00-00 00:00:00',
                                  wo_failure_time,
                                  wo_creation_time)))) /
       60) / COUNT(wo_id))               AS '平均故障修复时间Min'
FROM wo_history
WHERE wo_type_type = 'CORR'
      AND wo_status = 8
      AND wo_finish_time <> '0000-00-00 00:00:00'
      AND DATE(wo_creation_time) BETWEEN :start_date AND :end_date
      AND location_code IN
          (SELECT location_code
           FROM asset_location
             INNER JOIN
             (SELECT
                location_lft,
                location_rgt
              FROM asset_location
              WHERE location_id = :location_id AND :location_id <> 0
             ) scope
           WHERE scope.location_lft <= asset_location.location_lft
                 AND scope.location_rgt >= asset_location.location_rgt)
      AND (wo_downtime <> 0 OR timediff(wo_finish_time,
                                        IF(wo_failure_time <> '0000-00-00 00:00:00',
                                           wo_failure_time,
                                           wo_creation_time)) > 0) -- get rid of negative downtime.
GROUP BY YEAR(wo_creation_time), MONTH(wo_creation_time)
ORDER BY wo_creation_time ASC