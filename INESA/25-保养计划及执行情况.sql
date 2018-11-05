-- INESA PM plan & result.
SELECT wo_id                                      AS 工单号
     , wo_name                                    AS 工单名称
     , CASE
         WHEN wo_status >= 6 AND wo_status < 9 AND wo_finish_time <> 0
                 THEN round(time_to_sec(timediff(wo_finish_time,
                                                 if(wo_start_time <> 0, wo_start_time, wo_schedule_time))) /
                            3600, 2)
         ELSE ''
       END                                        AS '耗时(小时)'
     , asset_code                                 AS 线体
     , wo_schedule_time                           AS 计划时间
     , employee_name                              AS 负责人
     , status_name_cn                             AS 状态
     , if(wo_finish_time = 0, '', wo_finish_time) AS 完成时间
     , wo_ff_3                                    AS 协助厂家
     , wo_ff_4                                    AS 外协人数
     , employee_qty                               AS 设备人数
  FROM
    (SELECT wo_list.wo_id
          , type_code
          , wo_name
          , asset_code
          , asset_name
          , wo_schedule_time
          , employee_name
          , wo_start_time
          , wo_finish_time
          , wo_status
          , status_name_cn
          , wo_freefield.wo_ff_3
          , wo_freefield.wo_ff_4
          , count(wo_list_employee.employee_id) AS employee_qty
       FROM wo_list
              INNER JOIN mic_type ON wo_list.wo_type_id = mic_type.type_id
              INNER JOIN asset_list ON wo_list.wo_asset_id = asset_list.asset_id
              INNER JOIN mic_status ON wo_list.wo_status = mic_status.status_id
              INNER JOIN admin_employee ON wo_list.wo_responsible_id = admin_employee.employee_id
              LEFT JOIN wo_freefield ON wo_list.wo_id = wo_freefield.wo_id
              LEFT JOIN wo_list_employee ON wo_list.wo_id = wo_list_employee.wo_id
       GROUP BY wo_list.wo_id

     UNION ALL SELECT wo_history.wo_id
                    , wo_type_code
                    , wo_name
                    , asset_code
                    , asset_name
                    , wo_schedule_time
                    , wo_responsible_name
                    , wo_start_time
                    , wo_finish_time
                    , wo_status
                    , status_name_cn
                    , wo_freefield.wo_ff_3
                    , wo_freefield.wo_ff_4
                    , count(wo_history_employee.employee_code) AS employee_qty
                 FROM wo_history
                        INNER JOIN mic_status ON wo_history.wo_status = mic_status.status_id
                        LEFT JOIN wo_freefield ON wo_history.wo_id = wo_freefield.wo_id
                        LEFT JOIN wo_history_employee
                          ON wo_history.wo_id = wo_history_employee.wo_id
                 GROUP BY wo_history.wo_id
    ) AS wo_all

  WHERE type_code = 'PM'
    AND wo_schedule_time BETWEEN :start_date AND :end_date;

-- Part 2
SELECT wo_id                  AS 工单号
     , wo_name                AS 工单名称
     , task_name              AS 任务名称
     , task_details           AS 任务细节
     , wo_task_result_updater AS 执行人
     , task_result_name_cn    AS 执行结果
  FROM
    (SELECT wo_list.wo_id
          , wo_name
          , type_code
          , task_name
          , task_details
          , wo_task_result_updater
          , task_result_name_cn
       FROM wo_list
              LEFT JOIN wo_list_task ON wo_list.wo_id = wo_list_task.wo_id
              LEFT JOIN mic_type ON wo_list.wo_type_id = mic_type.type_id
              LEFT JOIN eng_task ON wo_list_task.task_id = eng_task.task_id
              LEFT JOIN mic_task_result
                ON wo_list_task.task_result_code = mic_task_result.task_result_code
       WHERE wo_list.wo_id = :row

     UNION ALL

     SELECT wo_history.wo_id
          , wo_name
          , wo_type_code
          , eng_task.task_name
          , task_details
          , wo_task_result_updater
          , task_result_name_cn
       FROM wo_history
              LEFT JOIN wo_history_task ON wo_history.wo_id = wo_history_task.wo_id
              LEFT JOIN eng_task ON wo_history_task.task_id = eng_task.task_id
              LEFT JOIN mic_task_result
                ON wo_history_task.task_result_code = mic_task_result.task_result_code
       WHERE wo_history.wo_id = :row
    ) AS wo_all

    - -