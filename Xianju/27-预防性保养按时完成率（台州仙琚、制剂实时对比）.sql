SELECT location_code                              AS 编码
     , location_name                              AS 厂区
     , finish_on_time                             AS 按时完成数
     , all_pm_wo                                  AS 总保养工单数
     , round(finish_on_time / all_pm_wo * 100, 2) AS '按时完成率%'
  FROM
    (SELECT department.location_code
          , department.location_name
          , COUNT(IF(wo_finish_time <> '0000-00-00 00:00:00' AND
                     DATE(wo_target_time) >= DATE(wo_finish_time), 1,
                     IF(DATE(wo_target_time) > CURDATE() AND wo_finish_time = '0000-00-00 00:00:00',
                        1, NULL))) AS finish_on_time
          , count(wo_id)           AS all_pm_wo
       FROM
         (SELECT wo_id
               , wo_asset_id
               , location_lft
               , wo_schedule_time
               , wo_target_time
               , wo_finish_time
            FROM wo_list
                   INNER JOIN mic_type ON wo_list.wo_type_id = mic_type.type_id
                   INNER JOIN asset_list ON wo_list.wo_asset_id = asset_list.asset_id
                   INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
            WHERE type_type = 'CORR'

          UNION ALL

          SELECT wo_id
               , asset_id
               , location_lft
               , wo_schedule_time
               , wo_target_time
               , wo_finish_time
            FROM wo_history
                   INNER JOIN asset_location
                     ON wo_history.location_code = asset_location.location_code
            WHERE wo_type_type = 'CORR'
         ) AS wo_all
           INNER JOIN
             (SELECT location_code
                   , location_name
                   , location_lft
                   , location_rgt
                FROM asset_location
                WHERE location_level = 2
             ) AS department
             ON wo_all.location_lft BETWEEN department.location_lft AND department.location_rgt
       GROUP BY department.location_code
    ) AS PM_data