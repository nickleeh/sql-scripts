SELECT
  concat(all_wo.employee_code, " ", all_wo.employee_name) 员工,
  wo_id                                                   工单号,
  type_type                                               工单类型,
  mr_request_time                                         报修时间,
  mr_id                                                   报修单号,
  wo_failure_time                                         故障时间,
  wo_creation_time                                        工单创建时间
FROM
  (
    SELECT
      wo_list_employee.wo_employee_id,
      admin_employee.employee_code AS employee_code,
      admin_employee.employee_name AS employee_name,
      wo_list_employee.wo_id,
      mr_list.mr_request_time,
      wo_list.mr_id,
      wo_list.wo_failure_time,
      wo_list.wo_creation_time     AS wo_creation_time,
      mic_type.type_type           AS type_type
    FROM wo_list_employee
      LEFT JOIN admin_employee ON wo_list_employee.employee_id = admin_employee.employee_id
      LEFT JOIN wo_list ON wo_list.wo_id = wo_list_employee.wo_id
      LEFT JOIN mic_type ON wo_list.wo_type_id = mic_type.type_id
      LEFT JOIN mr_list ON wo_list.mr_id = mr_list.mr_id
    WHERE mic_type.type_type = 'CORR'

    UNION ALL

    SELECT
      wo_history_employee.wo_employee_id,
      employee_code,
      employee_name,
      wo_history_employee.wo_id,
      wo_history.mr_request_time,
      wo_history.mr_id,
      wo_history.wo_failure_time,
      wo_history.wo_creation_time AS wo_creation_time,
      wo_history.wo_type_type     AS type_type
    FROM wo_history_employee
      LEFT JOIN wo_history ON wo_history_employee.wo_id = wo_history.wo_id
    WHERE wo_type_type = 'CORR'
  ) all_wo
-- LEFT JOIN admin_employee ON admin_employee.employee_id = all_wo.wo_employee_id
-- LEFT JOIN mic_speciality ON admin_employee.employee_speciality_id = mic_speciality.speciality_id

WHERE if(all_wo.mr_id <> 0, all_wo.mr_request_time, all_wo.wo_failure_time) BETWEEN :start_date AND :end_date
      AND all_wo.employee_name = :xkey