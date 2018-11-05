SELECT /* Maintenance (CM) time of location responsible. */
    wo_responsible_code
     , admin_employee.employee_name
     , round(sum(if(wo_worked_hour = 0,
                    if(wo_finish_time = 0, 0, time_to_sec(timediff(wo_finish_time, wo_start_time)) / 60 / 60),
                    wo_worked_hour)), 2) AS mtime
FROM wo_history
       LEFT JOIN wo_history_employee ON wo_history.wo_id = wo_history_employee.wo_id
       LEFT JOIN admin_employee ON wo_history.wo_responsible_code = admin_employee.employee_code
WHERE employee_id IN
      (SELECT responsible_id AS employee_id FROM asset_location)
  AND wo_type_type = 'CORR'
GROUP BY wo_responsible_code
ORDER BY mtime DESC
