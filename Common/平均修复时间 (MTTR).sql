-- 平均修复时间 (MTTR)
-- When restoring time is computed automatically based on dates recorded in work order:

SELECT
    DATE_FORMAT(wo_creation_time, '%Y-%m') AS xkey
  , (SUM(TIME_TO_SEC(
             timediff(wo_finish_time, IF(wo_failure_time <> '0000-00-00 00:00:00', wo_failure_time, wo_creation_time)))
         / 3600) / COUNT(wo_id))           AS val
FROM wo_history
WHERE wo_type_type = 'CORR'
      AND wo_status = 8
      AND wo_finish_time <> '0000-00-00 00:00:00'
      AND DATE(wo_creation_time) BETWEEN :start_date AND :end_date
      AND location_code IN (
  SELECT location_code
  FROM asset_location
    INNER JOIN (
                 SELECT
                   location_lft
                   , location_rgt
                 FROM asset_location
                 WHERE location_id = :location_id AND :location_id <> 0
                 UNION ALL
                 SELECT
                   location_lft
                   , location_rgt
                 FROM admin_employee_location
                   NATURAL JOIN asset_location
                 WHERE employee_id = :employee_id AND :location_id = 0
                 UNION ALL
                 SELECT
                   location_lft
                   , location_rgt
                 FROM admin_employee
                   INNER JOIN asset_location ON location_id = employee_location_id
                 WHERE employee_id = :employee_id AND :location_id = 0
               ) scope
  WHERE scope.location_lft <= asset_location.location_lft
        AND scope.location_rgt >= asset_location.location_rgt
)
GROUP BY YEAR(wo_creation_time), MONTH(wo_creation_time)
ORDER BY wo_creation_time ASC

-- WHEN the MTTR IS based ON downtime recorded BY technicians AND operator IN WORK orders:

SELECT
    DATE_FORMAT(wo_creation_time, '%Y-%m') AS xkey
  , (SUM(wo_downtime) / COUNT(wo_id))      AS MTTR
FROM wo_history
WHERE wo_type_type = 'CORR'
      AND wo_status = 8
      AND DATE(wo_creation_time) BETWEEN :start_date AND :end_date
GROUP BY YEAR(wo_creation_time), MONTH(wo_creation_time)
ORDER BY wo_creation_time ASC
