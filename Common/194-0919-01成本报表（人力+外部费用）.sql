SELECT
  DATE_FORMAT(wo_creation_time, '%Y-%m') AS datep,
  SUM(wo_manpower_cost)                  AS 人力成本,
  SUM(wo_external_cost)                  AS 外部费用
FROM wo_history
WHERE DATE(wo_creation_time) BETWEEN :start_date AND :end_date
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
      AND (asset_function_code = :function_code OR :function_code = '')
      AND (asset_criticality_code = :criticality_code OR :criticality_code = '')
      AND asset_class_code like if(:asset_class_code = '', '%', :asset_class_code)
GROUP BY YEAR(wo_creation_time), MONTH(wo_creation_time)
ORDER BY wo_creation_time ASC;

