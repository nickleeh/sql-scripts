SELECT
    status_name_cn       工单状态
  , count(wo_list.wo_id) 数量
FROM wo_list
  INNER JOIN mic_status ON wo_list.wo_status = mic_status.status_id
  INNER JOIN wo_list_employee ON wo_list.wo_id = wo_list_employee.wo_id
  INNER JOIN admin_employee ON wo_list_employee.employee_id = admin_employee.employee_id
WHERE wo_creation_time BETWEEN :start_date AND :end_date
      AND employee_name LIKE '%外委%'
GROUP BY status_name_cn

UNION ALL

SELECT
  '总计'
  , count(wo_list.wo_id) 数量
FROM wo_list
  INNER JOIN mic_status ON wo_list.wo_status = mic_status.status_id
  INNER JOIN wo_list_employee ON wo_list.wo_id = wo_list_employee.wo_id
  INNER JOIN admin_employee ON wo_list_employee.employee_id = admin_employee.employee_id
WHERE wo_creation_time BETWEEN :start_date AND :end_date
      AND employee_name LIKE '%外委%'