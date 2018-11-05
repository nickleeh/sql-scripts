SELECT
 admin_employee.employee_name    员工姓名,
wo_list.wo_id     工单号,
 wo_list.wo_name     工单名称,
concat(wo_list.wo_status, ". ", mic_status.status_name_cn) 工单状态,
 wo_list.wo_creation_time    工单创建时间
FROM
 wo_list
 LEFT JOIN wo_list_employee ON wo_list.wo_id = wo_list_employee.wo_id
 LEFT JOIN admin_employee ON wo_list_employee.employee_id = admin_employee.employee_id
 LEFT JOIN mic_type ON wo_list.wo_type_id = mic_type.type_id
 left join mic_status on wo_list.wo_status = mic_status.status_id
WHERE
 (mic_type.type_code = 'LUB' or mic_type.type_code = 'INSP')
 AND wo_list.wo_creation_time BETWEEN :start_date AND :end_date
 and wo_list.wo_status < 7
ORDER BY admin_employee.employee_name;