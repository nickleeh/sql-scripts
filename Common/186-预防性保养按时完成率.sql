-- Part 1
SELECT
  DATE_FORMAT(wo_creation_time, '%Y-%m')                           AS xkey,
  CONCAT(100 * FORMAT(COUNT(IF(DATE(wo_target_time) >= DATE(wo_finish_time), 1,
                               IF(DATE(wo_target_time) > CURDATE() AND wo_finish_time = '0000-00-00 00:00:00', 1,
                                  NULL))) / COUNT(wo_id), 2), '%') AS val
FROM wo_history
WHERE wo_type_type = 'PREV'
      AND DATE(wo_creation_time) BETWEEN :start_date AND :end_date
      AND wo_status = 8
      AND location_code IN (
  SELECT DISTINCT location_code
  FROM asset_location
    INNER JOIN (
                 SELECT
                   location_lft,
                   location_rgt
                 FROM asset_location
                 WHERE location_id = :location_id AND :location_id <> 0
                 UNION ALL
                 SELECT
                   location_lft,
                   location_rgt
                 FROM admin_employee_location
                   NATURAL JOIN asset_location
                 WHERE employee_id = :employee_id AND :location_id = 0
                 UNION ALL
                 SELECT
                   location_lft,
                   location_rgt
                 FROM admin_employee
                   INNER JOIN asset_location ON location_id = employee_location_id
                 WHERE employee_id = :employee_id AND :location_id = 0
               ) scope
  WHERE scope.location_lft <= asset_location.location_lft
        AND scope.location_rgt >= asset_location.location_rgt
)
GROUP BY YEAR(wo_creation_time), MONTH(wo_creation_time)
ORDER BY wo_creation_time ASC;

-- part 2
SELECT
  wo_id                                                                  工单号,
  concat(asset_code, ' ', asset_name)                                    设备,
  wo_responsible_name                                                    负责人,
  wo_creation_time                                                       创建时间,
  wo_target_time                                                         目标时间,
  wo_finish_time                                                         完成时间,
  round(time_to_sec(timediff(wo_finish_time, wo_target_time)) / 3600, 2) `超时（小时）`
FROM wo_history
WHERE wo_type_type = 'PREV'
      AND DATE(wo_creation_time) BETWEEN DATE(concat(:ROW, '-01')) AND last_day(DATE(concat(:ROW, '-01')))
      AND wo_status = 8
      AND location_code IN
          (SELECT DISTINCT location_code
           FROM asset_location
             INNER JOIN (
                          SELECT
                            location_lft,
                            location_rgt
                          FROM asset_location
                          WHERE location_id = :location_id AND :location_id <> 0
                          UNION ALL
                          SELECT
                            location_lft,
                            location_rgt
                          FROM admin_employee_location
                            NATURAL JOIN asset_location
                          WHERE employee_id = :employee_id AND :location_id = 0
                          UNION ALL
                          SELECT
                            location_lft,
                            location_rgt
                          FROM admin_employee
                            INNER JOIN asset_location ON location_id = employee_location_id
                          WHERE employee_id = :employee_id AND :location_id = 0
                        ) scope
           WHERE scope.location_lft <= asset_location.location_lft
                 AND scope.location_rgt >= asset_location.location_rgt)
      AND DATE(wo_finish_time) > DATE(wo_target_time);
-- ;