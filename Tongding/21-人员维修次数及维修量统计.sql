SELECT
#     人员：人员维修次数及维修量统计 工时统计用“维修完成时间-维修开始时间”
    md1_ff_2                     AS 事业部
     , admin_employee.employee_code AS 员工编码
     , admin_employee.employee_name AS 名字
    #  , md1_ff_1                     AS 事业部
     , work_orders_qty              AS 工单数
     , worked_duration              AS '工时（小时）'
  FROM admin_employee
         INNER JOIN asset_location
           ON admin_employee.employee_location_id = asset_location.location_id
         INNER JOIN
           (SELECT md1_ff_1
                 , md1_ff_2
                 , location_lft
                 , location_rgt
              FROM mic_module_1
                     INNER JOIN asset_location
                       ON mic_module_1.md1_ff_1 = asset_location.location_code
           ) AS department
           ON asset_location.location_lft BETWEEN department.location_lft AND department.location_rgt
         LEFT JOIN # Total wo per employee
           (SELECT employee_code
                 , employee_name
                 , count(DISTINCT wo_id)                    AS work_orders_qty
                 , round(sum(worked_duration) / 60 / 60, 2) AS worked_duration
                 , wo_creation_time
              FROM
                ( # responsible in wo list.
                  SELECT wo_id
                       , employee_code
                       , employee_name
                       , wo_creation_time
                       , type_type
                       , CASE
                           WHEN wo_status < 6 OR wo_finish_time = 0
                                   THEN 0
                           ELSE time_to_sec(timediff(wo_finish_time,
                                                     if(wo_start_time <> 0, wo_start_time, wo_schedule_time)))
                         END AS worked_duration
                    FROM wo_list
                           INNER JOIN admin_employee
                             ON wo_list.wo_responsible_id = admin_employee.employee_id
                           INNER JOIN mic_type ON wo_list.wo_type_id = mic_type.type_id

                  UNION ALL

                  # employee in wo list.
                  SELECT wo_list.wo_id
                       , employee_code
                       , employee_name
                       , wo_creation_time
                       , type_type
                       , CASE
                           WHEN wo_status < 6 OR wo_finish_time = 0
                                   THEN 0
                           ELSE time_to_sec(timediff(wo_finish_time,
                                                     if(wo_start_time <> 0, wo_start_time, wo_schedule_time)))
                         END AS worked_duration
                    FROM wo_list
                           INNER JOIN wo_list_employee ON wo_list.wo_id = wo_list_employee.wo_id
                           INNER JOIN admin_employee
                             ON wo_list_employee.employee_id = admin_employee.employee_id
                           INNER JOIN mic_type ON wo_list.wo_type_id = mic_type.type_id

                  UNION ALL

                  # responsible in wo history
                  SELECT wo_id
                       , wo_responsible_code
                       , wo_responsible_name
                       , wo_creation_time
                       , wo_type_type
                       , CASE
                           WHEN wo_status > 8 OR wo_finish_time = 0
                                   THEN 0
                           ELSE time_to_sec(timediff(wo_finish_time,
                                                     if(wo_start_time <> 0, wo_start_time, wo_schedule_time)))
                         END
                    FROM wo_history

                  UNION ALL

                  # employee in wo history
                  SELECT wo_history.wo_id
                       , employee_code
                       , employee_name
                       , wo_creation_time
                       , wo_type_type
                       , CASE
                           WHEN wo_status > 8 OR wo_finish_time = 0
                                   THEN 0
                           ELSE time_to_sec(timediff(wo_finish_time,
                                                     if(wo_start_time <> 0, wo_start_time, wo_schedule_time)))
                         END
                    FROM wo_history
                           INNER JOIN wo_history_employee
                             ON wo_history.wo_id = wo_history_employee.wo_id
                ) AS all_wo
              WHERE type_type = 'CORR'
                AND wo_creation_time BETWEEN :start_date AND :end_date
              GROUP BY employee_code
           ) AS wo_per_employee ON admin_employee.employee_code = wo_per_employee.employee_code
  WHERE employee_role = 4
    AND wo_creation_time BETWEEN :start_date AND :end_date
  ORDER BY md1_ff_1, work_orders_qty DESC, worked_duration DESC;