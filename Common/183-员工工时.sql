-- 183 员工工时
-- First part
SELECT
  wo_history.location_name                  分厂,
  wo_history_employee.employee_name         '姓名',
  admin_employee_role.role_name_cn          角色,
  admin_employee.employee_code              工号,
  wo_history.wo_type_name                   工单类型,
  SUM(TIME_TO_SEC(wo_worked_hour)) / 3600   '工时小时',
  count(DISTINCT wo_history_employee.wo_id) '工单数'
FROM
  (SELECT
     location_lft,
     location_rgt
   FROM asset_location
   WHERE location_id = :location_id) AS T,
  wo_history_employee
  INNER JOIN wo_history ON wo_history.wo_id = wo_history_employee.wo_id
  LEFT JOIN admin_employee ON wo_history_employee.employee_code = admin_employee.employee_code
  LEFT JOIN admin_employee_role ON admin_employee.employee_role = admin_employee_role.role_id
  LEFT JOIN asset_location ON admin_employee.employee_location_id = asset_location.location_id
WHERE
  asset_location.location_lft BETWEEN t.location_lft AND t.location_rgt
  AND DATE(wo_archive_time) BETWEEN :start_date AND :end_date
  AND wo_history_employee.employee_code <> "E001"
  AND wo_worked_hour > 0
  AND wo_status = 8
GROUP BY wo_history.location_name, admin_employee.employee_name, wo_type_code
ORDER BY 工时小时 DESC;


-- Second part
SELECT DISTINCT
  wo_history.wo_id                                       工单号,
  wo_history.wo_name                                     工单名称,
  round(TIME_TO_SEC(wo_history_employee.wo_worked_hour) / 3600, 2) `工时（小时）`
FROM wo_history_employee
INNER JOIN wo_history
ON wo_history.wo_id = wo_history_employee.wo_id
WHERE DATE (wo_archive_time) BETWEEN :start_date AND :end_date
AND employee_name = :cell AND wo_worked_hour > 0
AND wo_status = 8
ORDER BY wo_history.wo_id DESC;
-- 
