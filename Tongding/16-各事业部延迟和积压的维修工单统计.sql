-- Part 1.
SELECT department.md1_ff_1                                                             AS 事业部编码
     , department.md1_ff_2                                                             AS 事业部名称
     , sum(if(wo_status < 6 AND wo_target_time <> 0 AND wo_target_time < now(), 1, 0)) AS 延迟的工单
     , sum(if(wo_status < 6 AND (wo_target_time = 0 OR wo_responsible_id = 0), 1, 0))  AS 积压的工单
  FROM
    (SELECT wo_id
          , wo_creation_time
          , location_lft
          , wo_target_time
          , wo_finish_time
          , wo_status
          , wo_responsible_id
       FROM wo_list
              INNER JOIN mic_type ON wo_list.wo_type_id = mic_type.type_id
              INNER JOIN asset_list ON wo_list.wo_asset_id = asset_list.asset_id
              INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
       WHERE type_code = 'CM'
         AND date(wo_creation_time) BETWEEN :start_date AND :end_date
    ) AS wo_cm
      RIGHT JOIN
        (SELECT md1_ff_1
              , md1_ff_2
              , location_lft
              , location_rgt
           FROM mic_module_1
                  INNER JOIN asset_location ON mic_module_1.md1_ff_1 = asset_location.location_code
        ) AS department ON wo_cm.location_lft BETWEEN department.location_lft AND department.location_rgt
  GROUP BY department.md1_ff_1
  ORDER BY 延迟的工单 DESC
--
-- Part 2
SELECT department.md1_ff_1
     , department.md1_ff_2
     , wo_id
     , wo_target_time
     , wo_finish_time
  FROM
    (SELECT wo_id
          , wo_creation_time
          , location_lft
          , wo_target_time
          , wo_finish_time
          , wo_status
          , wo_responsible_id
       FROM wo_list
              INNER JOIN mic_type ON wo_list.wo_type_id = mic_type.type_id
              INNER JOIN asset_list ON wo_list.wo_asset_id = asset_list.asset_id
              INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
       WHERE type_code = 'CM'
         AND date(wo_creation_time) BETWEEN :start_date AND :end_date
    ) AS wo_cm
      INNER JOIN
        (SELECT md1_ff_1
              , md1_ff_2
              , location_lft
              , location_rgt
           FROM mic_module_1
                  INNER JOIN asset_location ON mic_module_1.md1_ff_1 = asset_location.location_code
        ) AS department ON wo_cm.location_lft BETWEEN department.location_lft AND department.location_rgt
  WHERE wo_status < 6
    AND department.md1_ff_1 = :row
    AND ((:col = "延迟的工单" AND (wo_target_time <> 0 AND wo_target_time < now())) OR
         (:col = "积压的工单" AND (wo_target_time = 0 OR wo_responsible_id = 0)))