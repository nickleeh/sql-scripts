SELECT /* 停机时间：已归档的工单，按工单中填写的时间。未完成的工单，按从故障时间到现在的时间。 */
    weekofyear(wo_failure_time) AS 周次
     , asset_classification     AS 分类
     , sum(if(wo_ff_1 = 0 AND wo_status < 6,
              time_to_sec(timediff(now(), wo_failure_time)) / 3600,
              wo_ff_1))         AS '停机时间（小时）'
FROM (SELECT wo_failure_time, wo_asset_id, asset_class_code, wo_ff_1, criticality_code, type_code, wo_status
      FROM wo_list
             INNER JOIN asset_list ON wo_asset_id = asset_list.asset_id
             INNER JOIN mic_asset_class ON asset_list.asset_class_id = mic_asset_class.asset_class_id
             INNER JOIN wo_freefield ON wo_list.wo_id = wo_freefield.wo_id
             INNER JOIN mic_criticality ON asset_list.criticality_id = mic_criticality.criticality_id
             INNER JOIN mic_type ON wo_list.wo_type_id = mic_type.type_id

      UNION ALL

      SELECT wo_failure_time
           , asset_id
           , asset_class_code
           , wo_ff_1
           , asset_criticality_code AS criticality_code
           , wo_type_code           AS type_code
           , wo_status
      FROM wo_history
             INNER JOIN wo_freefield ON wo_history.wo_id = wo_freefield.wo_id) AS halt_data
       INNER JOIN (SELECT 'CNC' AS asset_classification, mic_asset_class.asset_class_code AS class_code
                   FROM asset_list
                          INNER JOIN mic_asset_class ON asset_list.asset_class_id = mic_asset_class.asset_class_id
                   WHERE asset_class_code IN ('V_CNC', 'H_CNC', 'G_CNC', 'LASER')

                   UNION ALL

                   SELECT 'PRESS' AS asset_classification, mic_asset_class.asset_class_code AS class_code
                   FROM asset_list
                          INNER JOIN mic_asset_class ON asset_list.asset_class_id = mic_asset_class.asset_class_id
                   WHERE asset_class_code IN ('HPRES', 'MPRES', 'HOTST')) AS classification
         ON halt_data.asset_class_code = classification.class_code

WHERE halt_data.criticality_code = 'A'
  AND type_code = 'CM'
GROUP BY weekofyear(wo_failure_time), asset_classification
;





