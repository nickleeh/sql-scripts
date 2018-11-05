SELECT
    total_work_time.asset_code                                                  '编码'
  , total_work_time.asset_name                                                  '单位'

  -- 实际作业率 = (总工作时间-总停机时间) / 总工作时间
  , round(
        (total_work_time - total_downtime) / total_work_time *
        100,
        2)                                                                      '实际作业率'

  -- 含限产大修作业率=总时间-计划检修-工艺停机-工艺故障-设备故障/总时间
  , round((total_work_time - planned_downtime - tech_downtime -
           tech_failure - asset_failure_time) / total_work_time * 100,
          2)                                                                    '含限产大修作业率'

  -- 设备故障率 = 设备故障停机时间／总时间
  , @asset_failure_rate := round(asset_failure_time / total_work_time * 100, 2) '设备故障率'

  -- 工艺故障率 = 工艺故障停机时间／总时间
  , @tech_failure_rate := round(tech_failure / total_work_time * 100, 2)        '工艺故障率'

  -- 综合故障率 = 设备故障率+工艺故障率
  , @asset_failure_rate + @tech_failure_rate AS                                 '综合故障率'

FROM
  (SELECT
     asset_code
     , asset_name
     , parameter_reading_value total_work_time
   FROM asset_parameter_reading
     LEFT JOIN asset_parameter ON asset_parameter_reading.parameter_id = asset_parameter.parameter_id
     LEFT JOIN asset_list ON asset_parameter.asset_id = asset_list.asset_id
   WHERE parameter_name = '总工作时间' AND parameter_reading_time BETWEEN :start_date AND :end_date) total_work_time

  INNER JOIN

  (SELECT
     asset_code
     , asset_name
     , parameter_reading_value asset_failure_time
   FROM asset_parameter_reading
     LEFT JOIN asset_parameter ON asset_parameter_reading.parameter_id = asset_parameter.parameter_id
     LEFT JOIN asset_list ON asset_parameter.asset_id = asset_list.asset_id
   WHERE parameter_name = '设备故障停机时间' AND parameter_reading_time BETWEEN :start_date AND :end_date) asset_failure_time
    ON total_work_time.asset_code = asset_failure_time.asset_code

  INNER JOIN

  (SELECT
     asset_code
     , asset_name
     , parameter_reading_value planned_downtime
   FROM asset_parameter_reading
     LEFT JOIN asset_parameter ON asset_parameter_reading.parameter_id = asset_parameter.parameter_id
     LEFT JOIN asset_list ON asset_parameter.asset_id = asset_list.asset_id
   WHERE parameter_name = '计划检修停机时间' AND parameter_reading_time BETWEEN :start_date AND :end_date) planned_downtime
    ON planned_downtime.asset_code = asset_failure_time.asset_code

  INNER JOIN

  (SELECT
     asset_code
     , asset_name
     , parameter_reading_value tech_downtime
   FROM asset_parameter_reading
     LEFT JOIN asset_parameter ON asset_parameter_reading.parameter_id = asset_parameter.parameter_id
     LEFT JOIN asset_list ON asset_parameter.asset_id = asset_list.asset_id
   WHERE parameter_name = '工艺停机时间' AND parameter_reading_time BETWEEN :start_date AND :end_date) tech_downtime
    ON tech_downtime.asset_code = asset_failure_time.asset_code

  INNER JOIN

  (SELECT
     asset_code
     , asset_name
     , parameter_reading_value tech_failure
   FROM asset_parameter_reading
     LEFT JOIN asset_parameter ON asset_parameter_reading.parameter_id = asset_parameter.parameter_id
     LEFT JOIN asset_list ON asset_parameter.asset_id = asset_list.asset_id
   WHERE parameter_name = '工艺故障停机时间' AND parameter_reading_time BETWEEN :start_date AND :end_date) tech_failure
    ON tech_failure.asset_code = asset_failure_time.asset_code

  INNER JOIN

  (SELECT
     asset_code
     , asset_name
     , parameter_reading_value total_downtime
   FROM asset_parameter_reading
     LEFT JOIN asset_parameter ON asset_parameter_reading.parameter_id = asset_parameter.parameter_id
     LEFT JOIN asset_list ON asset_parameter.asset_id = asset_list.asset_id
   WHERE parameter_name = '总停机时间' AND parameter_reading_time BETWEEN :start_date AND :end_date) total_downtime
    ON total_downtime.asset_code = asset_failure_time.asset_code