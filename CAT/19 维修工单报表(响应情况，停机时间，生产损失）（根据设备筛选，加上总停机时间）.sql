SELECT
    -- 19 维修工单报表(响应情况，停机时间，生产损失）（根据设备筛选，加上总停机时间）
    wo_corr.wo_id         AS '工单号'
     , wo_corr.wo_name    AS '工单名称'
     , wo_corr.asset_code AS '设备编码'
     , wo_corr.asset_name AS '设备名称'
     , response_in_5_min  AS '响应时间(5min)'
     , down_time          AS '停机时间(min)'
     , maintenance_time   AS '维修时间(min)'
    #      , total_down_time        AS 总停机时间
    #      , total_maintenance_time AS 总维修时间
  FROM
    (SELECT wo_id
          , wo_name
          , wo_history.asset_code
          , wo_history.asset_name
          , if(time_to_sec(timediff(wo_start_time, wo_creation_time)) / 60 < 5, 'Y',
               'N')                                                                             AS response_in_5_min
         /*（如果工单中故障机制有选择1.2；2.2；3.2；4.2；5.2；6.2；7.2；8.2；9.2；则不计算停机时间）*/
          , round(if(wo_failure_mechanism_subdivision_code LIKE '_.2', 0,
                     time_to_sec(timediff(wo_finish_time, wo_failure_time)) / 60),
                  2)                                                                            AS down_time
          , round(time_to_sec(
                    timediff(if(wo_confirmation_time <> 0, wo_confirmation_time, wo_archive_time),
                             if(wo_start_time <> 0, wo_start_time, wo_creation_time))) / 60,
                  2)                                                                            AS maintenance_time
       FROM
         (SELECT location_lft
               , location_rgt
            FROM asset_location
            WHERE location_id = :location_id
         ) AS T,
         wo_history
           INNER JOIN asset_location ON wo_history.location_code = asset_location.location_code
       WHERE wo_type_type = 'CORR'
         AND wo_status = 8
         AND date(wo_creation_time) BETWEEN :start_date AND :end_date
         AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
           /*如果没选择设备，就列出全部。如果选择了设备，只显示这台设备相关的数据。*/
         AND CASE
               WHEN :asset_id = 0 THEN TRUE
               ELSE wo_history.asset_id = :asset_id END
         AND CASE
               WHEN :asset_class_code = '' THEN TRUE
               ELSE asset_class_code = :asset_class_code END
    ) AS wo_corr
    /*      INNER JOIN
            (SELECT wo_history.asset_code                                                          AS asset_code
                 --（如果工单中故障机制有选择1.2；2.2；3.2；4.2；5.2；6.2；7.2；8.2；9.2；则不计算停机时间）
                  , round(sum(if(wo_failure_mechanism_subdivision_code LIKE '_.2', 0,
                                 time_to_sec(timediff(wo_finish_time, wo_failure_time)) / 60)),
                          2)                                                                       AS total_down_time
                  , round(sum(time_to_sec(timediff(if(wo_confirmation_time <> 0, wo_confirmation_time,
                                                      wo_archive_time),
                                                   if(wo_start_time <> 0, wo_start_time, wo_creation_time))) /
                              60),
                          2)                                                                       AS total_maintenance_time
               FROM
                 (SELECT location_lft
                       , location_rgt
                    FROM asset_location
                    WHERE location_id = :location_id
                 ) AS T,
                 wo_history
                   INNER JOIN asset_location ON wo_history.location_code = asset_location.location_code
               WHERE wo_type_type = 'CORR'
                 AND wo_status = 8
                 AND date(wo_creation_time) BETWEEN :start_date AND :end_date
                 AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
                   -- 如果没选择设备，就列出全部。如果选择了设备，只显示这台设备相关的数据。
                 AND CASE
                       WHEN :asset_id = 0 THEN TRUE
                       ELSE wo_history.asset_id = :asset_id END
               GROUP BY asset_code
            ) AS total_down_maintenance ON wo_corr.asset_code = total_down_maintenance.asset_code
    */

UNION ALL

SELECT '总计'
     , 'N/A'
     , 'N/A'
     , 'N/A'
     , 'N/A'
     , round(sum(if(wo_failure_mechanism_subdivision_code LIKE '_.2', 0,
                    time_to_sec(timediff(wo_finish_time, wo_failure_time)) / 60)),
             2) AS down_time_all
     , round(sum(time_to_sec(
                   timediff(if(wo_confirmation_time <> 0, wo_confirmation_time, wo_archive_time),
                            if(wo_start_time <> 0, wo_start_time, wo_creation_time))) / 60), 2)
    #      , 'N/A'
    #      , 'N/A'    AS maintenance_time_all
  FROM
    (SELECT location_lft
          , location_rgt
       FROM asset_location
       WHERE location_id = :location_id
    ) AS T,
    wo_history
      INNER JOIN asset_location ON wo_history.location_code = asset_location.location_code
  WHERE wo_type_type = 'CORR'
    AND wo_status = 8
    AND date(wo_creation_time) BETWEEN :start_date AND :end_date
    AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
      /*如果没选择设备，就列出全部。如果选择了设备，只显示这台设备相关的数据。*/
    AND CASE
          WHEN :asset_id = 0 THEN TRUE
          ELSE wo_history.asset_id = :asset_id END
    AND CASE
          WHEN :asset_class_code = '' THEN TRUE
          ELSE asset_class_code = :asset_class_code END
