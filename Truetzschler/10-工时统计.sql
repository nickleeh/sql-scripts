SELECT
    date_format(wo_creation_time, "%Y-%m")            '月份 Month'
  , admin_employee.employee_name                      '员工 Employee'
  , round(sum(time_to_sec(wo_worked_hour)) / 3600, 2) '工时（小时）Worked Hours'
FROM wo_history
  INNER JOIN wo_history_employee ON wo_history.wo_id = wo_history_employee.wo_id
  INNER JOIN admin_employee ON wo_history_employee.employee_code = admin_employee.employee_code
WHERE wo_status = 8
GROUP BY date_format(wo_creation_time, "%Y-%m"), admin_employee.employee_name