-- 二氧化碳灭火器检查记录表
SELECT wo_id                                         AS 工单号
     , concat(location_code, location_name)          AS 位置
     , asset_code                                    AS 设备编码
     , task_name                                     AS 任务名称
     , task_details                                  AS 细节
     , concat(task_result_code, task_result_name_cn) AS 结果
     , wo_schedule_time                              AS 安排时间
     , concat(parameter_code, parameter_name)        AS 参数
     , parameter_reading_value                       AS 读数
     , wo_task_result_updater                        AS 检查人
     , wo_task_result_time                           AS 检查日期
     , wo_task_remark                                AS 备注
  FROM
    (SELECT wo_list.wo_id
          , type_code
          , location_code
          , location_name
          , asset_code
          , task_name
          , task_details
          , wo_list_task.task_result_code
          , task_result_name_cn
          , wo_task_remark
          , wo_schedule_time
          , parameter_code
          , parameter_name
          , parameter_reading_value
          , wo_task_result_updater
          , wo_task_result_time
       FROM wo_list
              INNER JOIN asset_list ON wo_list.wo_asset_id = asset_list.asset_id
              INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
              INNER JOIN mic_type ON asset_list.asset_type_id = mic_type.type_id
              INNER JOIN wo_list_task ON wo_list.wo_id = wo_list_task.wo_id
              INNER JOIN eng_task ON wo_list_task.task_id = eng_task.task_id
              INNER JOIN mic_task_result
                ON wo_list_task.task_result_code = mic_task_result.task_result_code
              LEFT JOIN asset_parameter ON wo_list_task.parameter_id = asset_parameter.parameter_id
              LEFT JOIN asset_parameter_reading
                ON asset_parameter.parameter_id = asset_parameter_reading.parameter_id

     UNION ALL

     SELECT wo_history.wo_id
          , asset_type_code
          , location_code
          , location_name
          , wo_history.asset_code
          , wo_history_task.task_name
          , task_details
          , wo_history_task.task_result_code
          , task_result_name_cn
          , wo_task_remark
          , wo_schedule_time
          , wo_history_task.parameter_code
          , wo_history_task.parameter_name
          , parameter_reading_value
          , wo_task_result_updater
          , wo_task_result_time
       FROM wo_history
              INNER JOIN wo_history_task ON wo_history.wo_id = wo_history_task.wo_id
              INNER JOIN eng_task ON wo_history_task.task_id = eng_task.task_id
              INNER JOIN mic_task_result
                ON wo_history_task.task_result_code = mic_task_result.task_result_code
              LEFT JOIN asset_parameter
                ON wo_history_task.parameter_code = asset_parameter.parameter_code
              LEFT JOIN asset_parameter_reading
                ON asset_parameter.parameter_code = asset_parameter_reading.parameter_id
    ) AS pm_wo
  WHERE type_code = 'CO2'
    AND date(wo_schedule_time) BETWEEN :start_date AND :end_date