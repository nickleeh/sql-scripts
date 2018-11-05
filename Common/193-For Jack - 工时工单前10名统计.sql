SELECT
  employee_name AS                                 xkey,
  count(DISTINCT woid)                             工单数,
  round(sum(TIME_TO_SEC(wotime)) / 3600 / 1000, 2) `工时（千小时）`
FROM
  (SELECT
     wo_list_employee.wo_id woid,
     employee_name,
     if(wo_worked_hour = 0, timediff(if(wo_finish_time = 0, now(), wo_finish_time), wo_start_time),
        wo_worked_hour)     wotime
   FROM wo_list
     RIGHT JOIN wo_list_employee ON wo_list.wo_id = wo_list_employee.wo_id
     LEFT JOIN admin_employee ON wo_list_employee.employee_id = admin_employee.employee_id
   WHERE wo_status = 5

   UNION

   SELECT
     wo_history_employee.wo_id woid,
     employee_name,
     if(wo_worked_hour = 0,
        timediff(if(wo_finish_time = 0, wo_archive_time, wo_finish_time), wo_start_time),
        wo_worked_hour)        wotime
   FROM wo_history
     RIGHT JOIN wo_history_employee ON wo_history.wo_id = wo_history_employee.wo_id
   WHERE wo_status = 8) allwo
GROUP BY employee_name
ORDER BY `工时（千小时）` DESC, 工单数 DESC
LIMIT 20;

