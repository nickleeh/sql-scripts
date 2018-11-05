-- Part 1:
SELECT
  employee_name                             AS '姓名',
  SUM(TIME_TO_SEC(wo_worked_hour)) / 3600   AS '工时小时',
  count(DISTINCT wo_history_employee.wo_id) AS '工单数'
FROM wo_history_employee
  INNER JOIN wo_history ON wo_history.wo_id = wo_history_employee.wo_id
WHERE DATE(wo_archive_time) BETWEEN :start_date AND :end_date
      AND employee_code <> "E001"
      AND wo_worked_hour > 0
      AND wo_status = 8
GROUP BY employee_name
ORDER BY 工时小时 DESC;

-- Part 2:
SELECT DISTINCT
  wo_history.wo_id,
  wo_name,
  wo_status
FROM wo_history_employee
  INNER JOIN wo_history
    ON wo_history.wo_id = wo_history_employee.wo_id
WHERE DATE(wo_archive_time) BETWEEN :start_date AND :end_date
      AND employee_name = :row AND wo_worked_hour > 0
      AND wo_status = 8
ORDER BY wo_history.wo_id DESC;
