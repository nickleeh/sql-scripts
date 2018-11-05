/* 通鼎各事业部点检完成情况*/
SELECT department.md1_ff_1           AS 编码
     , department.md1_ff_2           AS 事业部
     , sum(if(wo_status < 6, 1, 0))  AS 未完成
     , sum(if(wo_status >= 6, 1, 0)) AS 已完成
     , count(wo_id)                  AS 总数
  FROM
    (SELECT wo_id
          , wo_creation_time
          , location_lft
          , wo_target_time
          , wo_finish_time
          , wo_status
       FROM wo_list
              INNER JOIN mic_type ON wo_list.wo_type_id = mic_type.type_id
              INNER JOIN asset_list ON wo_list.wo_asset_id = asset_list.asset_id
              INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
       WHERE type_code = 'INSP'
         AND wo_creation_time BETWEEN :start_date AND :end_date

     UNION ALL

     SELECT wo_id
          , wo_creation_time
          , location_lft
          , wo_target_time
          , wo_finish_time
          , wo_status
       FROM wo_history
              INNER JOIN asset_location ON wo_history.location_code = asset_location.location_code
       WHERE wo_type_code = 'INSP'
         AND wo_creation_time BETWEEN :start_date AND :end_date
    ) AS wo_insp
      INNER JOIN
        (SELECT md1_ff_1
              , md1_ff_2
              , location_lft
              , location_rgt
           FROM mic_module_1
                  INNER JOIN asset_location ON mic_module_1.md1_ff_1 = asset_location.location_code
        ) AS department
        ON wo_insp.location_lft BETWEEN department.location_lft AND department.location_rgt
  GROUP BY department.md1_ff_1
;

# Part 2:
SELECT department.md1_ff_1 AS 编码
     , department.md1_ff_2 AS 事业部
     , wo_id               AS 工单号
     , asset_code          AS 设备编码
     , asset_name          AS 设备名称
     , wo_name             AS 工单名称
     , wo_target_time      AS 目标时间
  FROM
    (SELECT wo_id
          , asset_code
          , asset_name
          , wo_name
          , wo_creation_time
          , location_lft
          , wo_target_time
          , wo_finish_time
          , wo_status
       FROM wo_list
              INNER JOIN mic_type ON wo_list.wo_type_id = mic_type.type_id
              INNER JOIN asset_list ON wo_list.wo_asset_id = asset_list.asset_id
              INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
       WHERE type_code = 'INSP'
         AND wo_creation_time BETWEEN :start_date AND :end_date

     UNION ALL

     SELECT wo_id
          , asset_code
          , asset_name
          , wo_name
          , wo_creation_time
          , location_lft
          , wo_target_time
          , wo_finish_time
          , wo_status
       FROM wo_history
              INNER JOIN asset_location ON wo_history.location_code = asset_location.location_code
       WHERE wo_type_code = 'INSP'
         AND wo_creation_time BETWEEN :start_date AND :end_date
    ) AS wo_insp
      INNER JOIN
        (SELECT md1_ff_1
              , md1_ff_2
              , location_lft
              , location_rgt
           FROM mic_module_1
                  INNER JOIN asset_location ON mic_module_1.md1_ff_1 = asset_location.location_code
        ) AS department
        ON wo_insp.location_lft BETWEEN department.location_lft AND department.location_rgt
  WHERE department.md1_ff_1 = :row
    AND ((:col = "未完成" AND wo_status < 6) OR (:col = "已完成" AND wo_status >= 6 AND wo_status <= 8))