SELECT
  DATE_FORMAT(wo_creation_time, '%Y-%m') AS xkey,
  CONCAT(100 * FORMAT(COUNT(IF(DATE(wo_target_time) >= DATE(wo_finish_time),
                               1,
                               IF(DATE(wo_target_time) > CURDATE()
                                  AND wo_finish_time = '0000-00-00 00:00:00',
                                  1,
                                  NULL)))
                      / COUNT(wo_id), 2),
         '%')                            AS val
FROM wo_history
WHERE wo_type_type = 'PREV'
      AND DATE(wo_creation_time) BETWEEN :start_date AND :end_date
      AND wo_status = 8
      AND location_code IN (
        SELECT location_code
        FROM asset_location
        WHERE location_lft >= (SELECT location_lft
                               FROM asset_location
                               WHERE location_id = :location_id)
              AND location_rgt <= (SELECT location_rgt
                                   FROM asset_location
                                   WHERE location_id = :location_id)
      )
GROUP BY YEAR(wo_creation_time), MONTH(wo_creation_time)
ORDER BY wo_creation_time ASC