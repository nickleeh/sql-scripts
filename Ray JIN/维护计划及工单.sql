-- Ray，维护计划及工单。
SELECT @cnt := @cnt + 1                                              AS 序号
     , (SELECT location_name
        FROM asset_location AS asset_location_2
        WHERE location_code = left(asset_location.location_code, 2)) AS 工厂
     , asset_code                                                    AS 设备编码
     , asset_name                                                    AS 设备名称
     , task_name                                                     AS 任务
     , ''                                                            AS '预计时间（H）'
     , mp_description                                                AS 保全中注意事项
     , mp_next_date                                                  AS 计划时间
     , (SELECT employee_name
        FROM admin_employee
        WHERE employee_id = mp_responsible_id)                       AS 负责人
     , (SELECT group_concat(employee_name SEPARATOR ' ')
        FROM admin_employee
        WHERE employee_id IN
              (SELECT employee_id
               FROM eng_maintenance_plan_employee
               WHERE eng_maintenance_plan_employee.mp_id = eng_maintenance_plan.mp_id)
        GROUP BY eng_maintenance_plan.mp_id)                         AS 执行员工
FROM
  (SELECT @cnt := 0) AS cnt,
  eng_maintenance_plan
    INNER JOIN asset_list ON eng_maintenance_plan.mp_asset_id = asset_list.asset_id
    INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
    INNER JOIN eng_maintenance_plan_task ON eng_maintenance_plan.mp_id = eng_maintenance_plan_task.mp_id
    INNER JOIN eng_task ON eng_maintenance_plan_task.task_id = eng_task.task_id
WHERE mp_next_date BETWEEN :start_date AND :end_date
  AND asset_list.location_id = :location_id
  AND (SELECT speciality_code
       FROM mic_speciality
       WHERE speciality_id = mp_speciality_id) = :speciality_code

UNION

SELECT '序号'
     , '工厂'
     , '设备编码'
     , '设备名称'
     , '任务'
     , '预计时间（H）'
     , '保全中注意事项'
     , '计划时间'
     , '负责人'
     , '执行员工'

UNION

SELECT @cnt2 := @cnt2 + 1 AS 序号
     , (SELECT location_name
        FROM asset_location AS asset_location_3
        WHERE location_code = left(asset_location.location_code, 2))
     , asset_code
     , asset_name
     , task_name
     , ''                 AS '预计时间（H）'
     , wo_description
     , wo_schedule_time
     , (SELECT employee_name
        FROM admin_employee
        WHERE employee_id = responsible_id)
     , (SELECT group_concat(employee_name SEPARATOR ' ')
        FROM admin_employee
        WHERE employee_id IN (SELECT employee_id
                              FROM wo_list_employee
                              WHERE wo_list_employee.wo_id = wo_list.wo_id)
        GROUP BY wo_list.wo_id)
FROM
  (SELECT @cnt2 := 0) AS cnt2,
  wo_list
    INNER JOIN asset_list ON wo_list.wo_asset_id = asset_list.asset_id
    INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
    INNER JOIN wo_list_task ON wo_list.wo_id = wo_list_task.wo_id
    INNER JOIN eng_task ON wo_list_task.task_id = eng_task.task_id
WHERE wo_schedule_time BETWEEN :start_date AND :end_date
  AND asset_list.location_id = :location_id
  AND (SELECT speciality_code
       FROM mic_speciality
       WHERE speciality_id = wo_speciality_id) = :speciality_code
