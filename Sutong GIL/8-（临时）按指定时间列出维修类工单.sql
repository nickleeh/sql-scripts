SELECT
  wo_id                        工单号,
  wo_name                      工单名称,
  wo_failure_time              故障时间,
  wo_creator                   工单创建人,
  wo_description               工单描述,
  admin_employee.employee_name 负责人,
  wo_feedback                  工单反馈,
  wo_confirmor                 确认人
FROM wo_list
  LEFT JOIN mic_type ON wo_list.wo_type_id = mic_type.type_id
  LEFT JOIN admin_employee ON wo_list.wo_responsible_id = admin_employee.employee_id
WHERE mic_type.type_code = 'CM'
      AND wo_list.wo_failure_time BETWEEN :start_date AND :end_date;