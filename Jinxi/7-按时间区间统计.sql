SELECT
    g_location_code                                                                                    '位置'
  , g_location_name                                                                                    '名称'
  /*
        总停机时间 = 外围影响停机时间 + 大中修停机时间 + 计划检修停机时间 + 工艺停机时间 + 工艺故障时间+ 机械设备故障时间 +
                    电气故障时间 + 自动化故障时间
                    （每天录入的参数值的累加）
  */
  , @total_downtime :=
    outside_downtime + repair_downtime + planned_downtime + tech_downtime + tech_failure + mec_downtime + ele_downtime +
    automation_downtime                                                                                '总停机时间'
  -- 实际作业率 = (总工作时间-总停机时间) / 总工作时间
  , round((total_work_time - @total_downtime) / total_work_time * 100, 2)                              '实际作业率'

  -- 含限产大修作业率=总时间-计划检修-工艺停机-工艺故障-设备故障/总时间
  , round((total_work_time - planned_downtime - tech_downtime - tech_failure - asset_failure_time) / total_work_time *
          100, 2)                                                                                      '含限产大修作业率'

  -- (机械、电气、自动化）设备故障停机时间／总工作时间
  , @mec_failure_rate := round(mec_downtime / total_work_time * 100, 2)                                '机械故障率'
  , @ele_failure_rate := round(ele_downtime / total_work_time * 100, 2)                                '电气故障率'
  , @automation_failure_rate := round(automation_downtime / total_work_time * 100, 2)                  '自动化故障率'

  -- xx设备故障率 = 设备故障停机时间／总时间xx
  -- , @asset_failure_rate := round(asset_failure_time / total_work_time * 100, 2)                        '设备故障率'
  -- 设备故障率 = 机械设备故障率+电气设备故障率+自动化设备故障率
  , @asset_failure_rate := round(@mec_failure_rate + @ele_failure_rate + @automation_failure_rate, 2)  '设备故障率'
  -- 工艺故障率 = 工艺故障停机时间／总时间
  , @tech_failure_rate := round(tech_failure / total_work_time * 100, 2)                               '工艺故障率'

  -- 综合故障率=机械故障率+电气故障率+自动化故障率+工艺故障率
  , round(@mec_failure_rate + @ele_failure_rate + @automation_failure_rate + @tech_failure_rate, 2) AS '综合故障率'
  , repair_downtime                                                                                    '大中修停机时间'
  , planned_maintenance_downtime                                                                       '计划检修停机时间'
  , tech_downtime                                                                                      '工艺停机时间'
  , outside_downtime                                                                                   '外围影响停机时间'
  , tech_failure                                                                                       '工艺故障停机时间'
  , total_work_time                                                                                    '总工作时间'
  , mec_downtime                                                                                       '设备机械故障停机时间'
  , ele_downtime                                                                                       '设备电气故障停机时间'
  , automation_downtime                                                                                '设备自动化故障停机时间'
FROM
  (SELECT
       T.location_code                                                     AS g_location_code
     , T.location_name                                                     AS g_location_name
     , sum(IF(parameter_name = '设备当天运行时间', parameter_reading_value, 0))    AS total_work_time
     , sum(IF(parameter_name = '设备机械故障停机时间', parameter_reading_value, 0))  AS asset_failure_time
     , sum(IF(parameter_name = '计划检修停机时间', parameter_reading_value, 0))    AS planned_downtime
     , sum(IF(parameter_name = '工艺停机时间', parameter_reading_value, 0))      AS tech_downtime
     , sum(IF(parameter_name = '工艺故障停机时间', parameter_reading_value, 0))    AS tech_failure
     , sum(IF(parameter_name = '设备机械故障停机时间', parameter_reading_value, 0))  AS mec_downtime
     , sum(IF(parameter_name = '设备电气故障停机时间', parameter_reading_value, 0))  AS ele_downtime
     , sum(IF(parameter_name = '设备自动化故障停机时间', parameter_reading_value, 0)) AS automation_downtime
     , sum(IF(parameter_name = '大中修停机时间', parameter_reading_value, 0))     AS repair_downtime
     , sum(IF(parameter_name = '外围影响停机时间', parameter_reading_value, 0))    AS outside_downtime
     , sum(IF(parameter_name = '计划检修停机时间', parameter_reading_value, 0))    AS planned_maintenance_downtime
   FROM
     asset_parameter_reading
     LEFT JOIN asset_parameter ON asset_parameter_reading.parameter_id = asset_parameter.parameter_id
     LEFT JOIN asset_list ON asset_parameter.asset_id = asset_list.asset_id
     LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
     LEFT JOIN
     (SELECT
        location_id
        , location_code
        , location_name
        , location_lft
        , location_rgt
      FROM asset_location
      WHERE location_is_entity = 1
            AND location_code LIKE '%-%') AS T
       ON asset_location.location_lft BETWEEN t.location_lft AND t.location_rgt
   WHERE parameter_reading_time BETWEEN :start_date AND STR_TO_DATE(CONCAT(:end_date, ' ', '23:59:00'),
                                                                    '%Y-%m-%d %H:%i:%s')
   GROUP BY g_location_code
  ) AS para_join_entity;
--

-- Part 2.
SELECT
    DATE(wo_schedule_time) '日期'
  , wo_history.asset_code  '编码'
  , wo_history.asset_name  '名称'
  , parameter_reading_time '停机时间'
  , wo_task_remark         '停机原因'
FROM
  wo_history_task
  LEFT JOIN asset_parameter_reading ON wo_history_task.wo_task_id = asset_parameter_reading.wo_task_id
  LEFT JOIN wo_history ON wo_history_task.wo_id = wo_history.wo_id
  LEFT JOIN asset_location ON wo_history.location_code = asset_location.location_code
WHERE
  parameter_reading_value <> 0
  AND wo_task_remark <> ''
  AND wo_schedule_time BETWEEN :start_date AND STR_TO_DATE(CONCAT(:end_date, ' ', '23:59:00'), '%Y-%m-%d %H:%i:%s');
--