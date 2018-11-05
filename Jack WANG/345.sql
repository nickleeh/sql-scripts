SELECT sta             AS 任务状态
     , count(a.result) AS 数量
  FROM
    (SELECT wo_history_task.wo_id                                              AS 工单号
          , wo_name                                                            AS 工单名称
          , wo_status                                                          AS 状态
          , wo_history.asset_code                                              AS 设备编码
          , wo_history.asset_name                                              AS 设备名称
          , concat(mic_task_result.task_result_code, '.', task_result_name_cn) AS sta
          , wo_history_task.task_result_code                                   AS result
          , eng_task.task_name                                                 AS 任务名称
          , wo_task_remark                                                     AS 备注
          , wo_task_result_time                                                AS 任务完成时间
          , wo_task_result_updater                                             AS 执行人
       FROM wo_history_task
              LEFT JOIN mic_task_result
                ON wo_history_task.task_result_code = mic_task_result.task_result_code
              LEFT JOIN wo_history ON wo_history.wo_id = wo_history_task.wo_id
              LEFT JOIN eng_task ON eng_task.task_id = wo_history_task.task_id
              LEFT JOIN asset_list ON wo_history.asset_id = asset_list.asset_id
              LEFT JOIN mic_function ON asset_list.function_id = mic_function.function_id

       WHERE date(wo_creation_time) BETWEEN :start_date AND :end_date
         AND wo_status <> 9
         AND (wo_history.wo_speciality_code = :speciality_code OR :speciality_code = '')
         AND (wo_history.wo_type_code = :type_code OR :type_code = '')
         AND (function_code = :function_code OR :function_code = '')


     UNION ALL

     SELECT wo_list.wo_id                                                      AS 工单号
          , wo_name                                                            AS 工单名称
          , wo_status                                                          AS 状态
          , asset_code                                                         AS 设备编码
          , asset_name                                                         AS 设备名称
          , concat(mic_task_result.task_result_code, '.', task_result_name_cn) AS 任务状态
          , wo_list_task.task_result_code
          , task_name                                                          AS 任务名称
          , wo_task_remark                                                     AS 备注
          , wo_task_result_time                                                AS 任务完成时间
          , wo_task_result_updater                                             AS 执行人
       FROM wo_list_task
              LEFT JOIN mic_task_result
                ON wo_list_task.task_result_code = mic_task_result.task_result_code
              LEFT JOIN wo_list ON wo_list_task.wo_id = wo_list.wo_id
              LEFT JOIN asset_list ON wo_list.wo_asset_id = asset_list.asset_id
              LEFT JOIN eng_task ON wo_list_task.task_id = eng_task.task_id
              LEFT JOIN mic_speciality ON mic_speciality.speciality_id = wo_list.wo_speciality_id
              LEFT JOIN mic_type ON mic_type.type_id = wo_list.wo_type_id
              LEFT JOIN mic_function ON asset_list.function_id = mic_function.function_id
       WHERE date(wo_creation_time) BETWEEN :start_date AND :end_date
         AND (mic_speciality.speciality_code = :speciality_code OR :speciality_code = '')
         AND (mic_type.type_code = :type_code OR :type_code = '')
         AND (function_code = :function_code OR :function_code = '')
    ) a
  GROUP BY sta