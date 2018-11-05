SELECT
    admin_employee.employee_name 姓名
  , mtime                        维修时间
FROM
  (SELECT
       wo_history_employee.employee_name name
     , round(sum(if(wo_worked_hour = 0,
                    if(wo_finish_time = 0, 0, time_to_sec(timediff(wo_finish_time, wo_start_time)) / 60 / 60),
                    wo_worked_hour)), 2) mtime
   FROM wo_history
     INNER JOIN wo_history_employee ON wo_history.wo_id = wo_history_employee.wo_id
   WHERE wo_type_code = 'CM' AND wo_start_time BETWEEN :start_date AND :end_date
   GROUP BY wo_history_employee.employee_name) data
  RIGHT JOIN admin_employee ON data.name = admin_employee.employee_name
WHERE admin_employee.employee_role IN (3, 4, 5)
ORDER BY mtime DESC;