-- 周报表
SELECT
    total_work_time.asset_code                                                                         '编码'
  , total_work_time.asset_name                                                                         '单位'
  -- 考核作业率 = 参数录入数值
  , ifnull(accessment_rate, 0)                                                                         '考核作业率'
  -- 实际作业率 = (总工作时间-总停机时间) / 总工作时间
  , round(
        (total_work_time - total_downtime) / total_work_time *
        100,
        2)                                                                                             '实际作业率'

  -- 含限产大修作业率=总时间-计划检修-工艺停机-工艺故障-设备故障/总时间
  , round((total_work_time - planned_downtime - tech_downtime -
           tech_failure - asset_failure_time) / total_work_time * 100,
          2)                                                                                           '含限产大修作业率'

  -- (机械、电气、自动化）设备故障停机时间／总工作时间
  , @mec_failure_rate := round(ifnull(mec_downtime, 0) / total_work_time * 100, 2)                     '机械故障率'
  , @ele_failure_rate := round(ifnull(ele_downtime, 0) / total_work_time * 100, 2)                     '电气故障率'
  , @automation_failure_rate := round(ifnull(automation_downtime, 0) / total_work_time * 100, 2)       '自动化故障率'

  -- 设备故障率 = 设备故障停机时间／总时间
  , @asset_failure_rate := round(asset_failure_time / total_work_time * 100, 2)                        '设备故障率'

  -- 工艺故障率 = 工艺故障停机时间／总时间
  , @tech_failure_rate := round(tech_failure / total_work_time * 100, 2)                               '工艺故障率'

  -- 综合故障率=机械故障率+电气故障率+自动化故障率+工艺故障率
  , round(@mec_failure_rate + @ele_failure_rate + @automation_failure_rate + @tech_failure_rate, 2) AS '综合故障率'
  , ifnull(repair_downtime, 0)                                                                         '大中修停机时间'
  , ifnull(planned_maintenance_downtime, 0)                                                            '计划检修停机时间'
  , ifnull(tech_downtime, 0)                                                                           '工艺停机时间'
  , ifnull(outside_downtime, 0)                                                                        '外围影响停机时间'
  , ifnull(tech_failure, 0)                                                                            '工艺故障停机时间'
  , ifnull(total_downtime, 0)                                                                          '总停机时间'
  , ifnull(total_work_time, 0)                                                                         '总工作时间'
  , ifnull(mec_downtime, 0)                                                                            '设备机械故障停机时间'
  , ifnull(ele_downtime, 0)                                                                            '设备电气故障停机时间'
  , ifnull(automation_downtime, 0)                                                                     '设备自动化故障停机时间'
FROM
  (SELECT
     asset_code
     , asset_name
     , parameter_reading_value total_work_time
   FROM
     (SELECT
        location_lft
        , location_rgt
      FROM asset_location
      WHERE location_id = :location_id) AS T,
     asset_parameter_reading
     LEFT JOIN asset_parameter ON asset_parameter_reading.parameter_id = asset_parameter.parameter_id
     LEFT JOIN asset_list ON asset_parameter.asset_id = asset_list.asset_id
     LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
   WHERE parameter_name = '总工作时间' AND parameter_reading_time BETWEEN :start_date AND :end_date
         AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt) total_work_time

  INNER JOIN

  (SELECT
     asset_code
     , asset_name
     , parameter_reading_value asset_failure_time
   FROM asset_parameter_reading
     LEFT JOIN asset_parameter ON asset_parameter_reading.parameter_id = asset_parameter.parameter_id
     LEFT JOIN asset_list ON asset_parameter.asset_id = asset_list.asset_id
   WHERE parameter_name = '设备机械故障停机时间' AND parameter_reading_time BETWEEN :start_date AND :end_date) asset_failure_time
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

  LEFT JOIN

  (SELECT
     asset_code
     , asset_name
     , parameter_reading_value accessment_rate
   FROM asset_parameter_reading
     LEFT JOIN asset_parameter ON asset_parameter_reading.parameter_id = asset_parameter.parameter_id
     LEFT JOIN asset_list ON asset_parameter.asset_id = asset_list.asset_id
   WHERE parameter_name = '考核作业率' AND parameter_reading_time BETWEEN :start_date AND :end_date) accessment_rate
    ON accessment_rate.asset_code = asset_failure_time.asset_code

  LEFT JOIN

  (SELECT
     asset_code
     , asset_name
     , parameter_reading_value mec_downtime
   FROM asset_parameter_reading
     LEFT JOIN asset_parameter ON asset_parameter_reading.parameter_id = asset_parameter.parameter_id
     LEFT JOIN asset_list ON asset_parameter.asset_id = asset_list.asset_id
   WHERE parameter_name = '设备机械故障停机时间' AND parameter_reading_time BETWEEN :start_date AND :end_date) mec_downtime
    ON mec_downtime.asset_code = asset_failure_time.asset_code

  LEFT JOIN

  (SELECT
     asset_code
     , asset_name
     , parameter_reading_value ele_downtime
   FROM asset_parameter_reading
     LEFT JOIN asset_parameter ON asset_parameter_reading.parameter_id = asset_parameter.parameter_id
     LEFT JOIN asset_list ON asset_parameter.asset_id = asset_list.asset_id
   WHERE parameter_name = '设备电气故障停机时间' AND parameter_reading_time BETWEEN :start_date AND :end_date) ele_downtime
    ON ele_downtime.asset_code = asset_failure_time.asset_code

  LEFT JOIN

  (SELECT
     asset_code
     , asset_name
     , parameter_reading_value automation_downtime
   FROM asset_parameter_reading
     LEFT JOIN asset_parameter ON asset_parameter_reading.parameter_id = asset_parameter.parameter_id
     LEFT JOIN asset_list ON asset_parameter.asset_id = asset_list.asset_id
   WHERE
     parameter_name = '设备自动化故障停机时间' AND parameter_reading_time BETWEEN :start_date AND :end_date) automation_downtime
    ON automation_downtime.asset_code = asset_failure_time.asset_code

  LEFT JOIN

  (SELECT
     asset_code
     , asset_name
     , parameter_reading_value repair_downtime
   FROM asset_parameter_reading
     LEFT JOIN asset_parameter ON asset_parameter_reading.parameter_id = asset_parameter.parameter_id
     LEFT JOIN asset_list ON asset_parameter.asset_id = asset_list.asset_id
   WHERE
     parameter_name = '大中修停机时间' AND parameter_reading_time BETWEEN :start_date AND :end_date) repair_downtime
    ON repair_downtime.asset_code = asset_failure_time.asset_code

  LEFT JOIN

  (SELECT
     asset_code
     , asset_name
     , parameter_reading_value planned_maintenance_downtime
   FROM asset_parameter_reading
     LEFT JOIN asset_parameter ON asset_parameter_reading.parameter_id = asset_parameter.parameter_id
     LEFT JOIN asset_list ON asset_parameter.asset_id = asset_list.asset_id
   WHERE
     parameter_name = '计划检修停机时间' AND
     parameter_reading_time BETWEEN :start_date AND :end_date) planned_maintenance_downtime
    ON planned_maintenance_downtime.asset_code = asset_failure_time.asset_code

  LEFT JOIN

  (SELECT
     asset_code
     , asset_name
     , parameter_reading_value outside_downtime
   FROM asset_parameter_reading
     LEFT JOIN asset_parameter ON asset_parameter_reading.parameter_id = asset_parameter.parameter_id
     LEFT JOIN asset_list ON asset_parameter.asset_id = asset_list.asset_id
   WHERE
     parameter_name = '外围影响停机时间' AND parameter_reading_time BETWEEN :start_date AND :end_date) outside_downtime
    ON outside_downtime.asset_code = asset_failure_time.asset_code


-- ORDER BY ele_downtime.asset_code
;
--