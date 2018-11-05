SELECT
  mr_list.mr_id                                                                                                报修号,
  mr_name                                                                                                      报修名称,
  #   mr_description                                 描述,
  mr_failure_time                                                                                              故障时间,
  mr_requester                                                                                                 报修人,
  CASE mr_status
  WHEN 0
    THEN '已创建'
  WHEN 6
    THEN '已验证'
  WHEN 9
    THEN '已取消' END                                                                                             状态,
  wo_list.wo_id                                                                                                工单号,
  employee_name                                                                                                工单负责人,
  (SELECT GROUP_CONCAT(employee_name SEPARATOR ', ')
   FROM wo_list_employee
     LEFT JOIN admin_employee ON wo_list_employee.employee_id = admin_employee.employee_id
   WHERE wo_list_employee.wo_id = wo_list.wo_id)                                                               维修工,
  mic_status.status_name_cn                                                                                    工单状态,
  if(wo_status IN (6, 7), timediff(wo_finish_time, wo_list.wo_failure_time), timediff(now(), wo_failure_time)) 用时
FROM mr_list
  LEFT JOIN wo_list ON mr_list.mr_id = wo_list.mr_id
  LEFT JOIN admin_employee ON wo_list.wo_responsible_id = admin_employee.employee_id
  LEFT JOIN wo_list_employee ON wo_list.wo_id = wo_list_employee.wo_id
  LEFT JOIN mic_status ON wo_list.wo_status = mic_status.status_id