SELECT
    md2_ff_1                   AS                                              `Date 日期`
  , md2_ff_2                   AS                                              'Shift 班次'
  , md2_ff_3                   AS                                              'Product Number 产品卡号'
  , concat(location_code, '-',
           location_name)      AS                                              'Line 线别'
  , md2_ff_4                   AS                                              'Working Time 工作时间（小时）'
  , md4_ff_6                   AS                                              'ST标准工时'
  /*
   * md4_ff_5 "时间time(sec)"
   * md4_ff_6 "time (sec)*1.10时间*1.10"
  */
  , md4_ff_7                   AS                                              'STD worker 标准人数'
  , @st_production := round(md2_ff_4 * 3600 / md4_ff_6 * md2_ff_5 / md4_ff_7,
                            2) AS                                              'STD output 标准产量'
  , @oee_st_production :=
    round(round(md2_ff_4 - md2_ff_7 / 60 - md2_ff_8 / 60, 2) * 3600 / (md4_ff_6 / 1.15) * md2_ff_5 / md4_ff_7,
          2)                   AS                                              'STD output(ST/1.1)标准产量'
  , md2_ff_5                   AS                                              'Fact worker 实际人数'
  , md2_ff_6                   AS                                              '实际产量'
  , md2_ff_7                                                                   'PT 计划停机时间'
  , md2_ff_8                                                                   'UPT 计划外停机时间'
  , @available_time := round(md2_ff_4 - md2_ff_7 / 60 - md2_ff_8 / 60, 2)      '可用时间AT'
  , @actual_working_time := round(md2_ff_4 - md2_ff_7 / 60, 2)                 '负荷时间WT'
  , md2_ff_9                                                                   '报废SCRAP'
  , md2_ff_10                                                                  '返工REWORK'
  , md2_ff_12                                                                  '录入时间'
  , md2_ff_13                                                                  '文员'
  , @avaliable := round(@available_time / @actual_working_time * 100, 2)       '利用率 Utilization'
  , @performance := round((md2_ff_6 + md2_ff_9) / @oee_st_production * 100, 2) '达成率Finished rate'
  , round(md2_ff_6 / @st_production * 100, 2)                                  '生产效率efficiency'
  , @quality :=
    round((md2_ff_6 - md2_ff_10) / (md2_ff_6 + md2_ff_9) * 100, 2)             '合格率product percent of pass'
  , round(@avaliable * @performance * @quality / 10000, 2)                     'OEE'
FROM mic_module_2
  INNER JOIN asset_location ON mic_module_2.md2_ff_11 = asset_location.location_id
  /* md2_ff_11 'location_id' */
  LEFT JOIN mic_module_4 ON mic_module_2.md2_ff_3 = mic_module_4.md4_ff_2
  /* product number */
  , (SELECT
       location_lft
       , location_rgt
     FROM asset_location
     WHERE location_id = if(:location_id = 0, 1, :location_id)) AS T
WHERE md2_ff_12 BETWEEN :start_date AND concat(:end_date, ' 23:59')
      AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt

UNION ALL

SELECT
  '统计'
  , 'N/A'                                       AS 'A2'
  , 'N/A'                                       AS 'A3'
  , 'N/A'                                       AS 'A4'
  , 'N/A'                                       AS 'A5'
  , 'N/A'                                       AS 'A6'
  , 'N/A'                                       AS 'A7'
  , 'N/A'                                       AS 'A8'
  , 'N/A'                                       AS 'A9'
  , 'N/A'                                       AS 'A10'
  , round(sum(实际产量), 2)                         AS 'quantity'
  , 'N/A'                                       AS 'A12'
  , 'N/A'                                       AS 'A13'
  , 'N/A'                                       AS 'A14'
  , 'N/A'                                       AS 'A15'
  , 'N/A'                                       AS 'A16'
  , 'N/A'                                       AS 'A17'
  , 'N/A'                                       AS 'A18'
  , 'N/A'                                       AS 'A19'
  , round(avg('利用率 Utilization'), 2)            AS 'utilization'
  , round(avg('达成率Finished rate'), 2)           AS 'finished_rate'
  , round(avg('生产效率efficiency'), 2)             AS 'performance'
  , round(avg('合格率product percent of pass'), 2) AS 'quality'
  , round(avg(OEE), 2)                          AS 'OEE'
FROM
  (SELECT
       md2_ff_1                   AS                                              `Date 日期`
     , md2_ff_2                   AS                                              'Shift 班次'
     , md2_ff_3                   AS                                              'Product Number 产品卡号'
     , concat(location_code, '-',
              location_name)      AS                                              'Line 线别'
     , md2_ff_4                   AS                                              'Working Time 工作时间（小时）'
     , md4_ff_6                   AS                                              'ST标准工时'
     /*
      * md4_ff_5 "时间time(sec)"
      * md4_ff_6 "time (sec)*1.10时间*1.10"
     */
     , md4_ff_7                   AS                                              'STD worker 标准人数'
     , @st_production := round(md2_ff_4 * 3600 / md4_ff_6 * md2_ff_5 / md4_ff_7,
                               2) AS                                              'STD output 标准产量'
     , @oee_st_production :=
       round(round(md2_ff_4 - md2_ff_7 / 60 - md2_ff_8 / 60, 2) * 3600 / (md4_ff_6 / 1.15) * md2_ff_5 / md4_ff_7,
             2)                   AS                                              'STD output(ST/1.1)标准产量'
     , md2_ff_5                   AS                                              'Fact worker 实际人数'
     , md2_ff_6                   AS                                              '实际产量'
     , md2_ff_7                                                                   'PT 计划停机时间'
     , md2_ff_8                                                                   'UPT 计划外停机时间'
     , @available_time := round(md2_ff_4 - md2_ff_7 / 60 - md2_ff_8 / 60, 2)      '可用时间AT'
     , @actual_working_time := round(md2_ff_4 - md2_ff_7 / 60, 2)                 '负荷时间WT'
     , md2_ff_9                                                                   '报废SCRAP'
     , md2_ff_10                                                                  '返工REWORK'
     , md2_ff_12                                                                  '录入时间'
     , md2_ff_13                                                                  '文员'
     , @avaliable := round(@available_time / @actual_working_time * 100, 2)       '利用率 Utilization'
     , @performance := round((md2_ff_6 + md2_ff_9) / @oee_st_production * 100, 2) '达成率Finished rate'
     , round(md2_ff_6 / @st_production * 100, 2)                                  '生产效率efficiency'
     , @quality :=
       round((md2_ff_6 - md2_ff_10) / (md2_ff_6 + md2_ff_9) * 100, 2)             '合格率product percent of pass'
     , round(@avaliable * @performance * @quality / 10000, 2)                     'OEE'
   FROM mic_module_2
     INNER JOIN asset_location ON mic_module_2.md2_ff_11 = asset_location.location_id
     /* md2_ff_11 'location_id' */
     LEFT JOIN mic_module_4 ON mic_module_2.md2_ff_3 = mic_module_4.md4_ff_2
     /* product number */
     , (SELECT
          location_lft
          , location_rgt
        FROM asset_location
        WHERE location_id = if(:location_id = 0, 1, :location_id)) AS T
   WHERE md2_ff_12 BETWEEN :start_date AND concat(:end_date, ' 23:59')
         AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt) AS data
