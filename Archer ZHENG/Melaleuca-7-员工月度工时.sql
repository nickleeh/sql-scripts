SELECT
    date_format(wo_creation_time, "%Y-%m") 月份
  , employee_name                          姓名
  , sum(time_to_sec(
            if(wo_worked_hour = 0, timediff(if(wo_finish_time = 0, wo_archive_time, wo_finish_time), wo_start_time),
               wo_worked_hour))) / 3600    '工时（小时）'
FROM wo_history
  INNER JOIN wo_history_employee ON wo_history.wo_id = wo_history_employee.wo_id
WHERE wo_status = 8
GROUP BY date_format(wo_creation_time, "%Y-%m"), employee_name