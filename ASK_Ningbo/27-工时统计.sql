SELECT
    employee_name                             姓名
  , sec_to_time(
        sum(time_to_sec(if(wo_worked_hour = 0,
                           timediff(wo_finish_time + INTERVAL 1 MINUTE, wo_start_time),
                           wo_worked_hour)))) 工时
FROM wo_history
  LEFT JOIN wo_history_employee ON wo_history.wo_id = wo_history_employee.wo_id
WHERE wo_start_time BETWEEN :start_date AND :end_date
GROUP BY employee_name
ORDER BY 工时 DESC;