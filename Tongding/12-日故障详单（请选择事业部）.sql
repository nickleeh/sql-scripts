SELECT wo_id                                                                                                  AS 工单号
     , asset_code                                                                                             AS 设备编码
     , asset_name                                                                                             AS 设备名称
     , wo_name                                                                                                AS 工单名称
     , wo_failure_time                                                                                        AS 故障时间
     , wo_finish_time                                                                                         AS 完成时间
     , if(wo_finish_time = 0, '未完成',
          round(time_to_sec(timediff(wo_finish_time, wo_failure_time)) / 3600, 2))                            AS '停机时间（小时）'
  FROM
    (SELECT location_code
          , location_name
          , location_lft
          , location_rgt
       FROM asset_location
       WHERE location_id = :location_id
    ) AS scope,
    (SELECT wo_id
          , wo_name
          , wo_failure_time
          , wo_finish_time
          , location_lft
          , type_code
          , asset_code
          , asset_name
       FROM wo_list
              INNER JOIN asset_list ON wo_list.wo_asset_id = asset_list.asset_id
              INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
              INNER JOIN mic_type ON wo_list.wo_type_id = mic_type.type_id

     UNION

     SELECT wo_id
          , wo_name
          , wo_failure_time
          , wo_finish_time
          , location_lft
          , wo_type_code
          , asset_code
          , asset_name
       FROM wo_history
              INNER JOIN asset_location ON wo_history.location_code = asset_location.location_code
    ) AS wo_all

  WHERE wo_all.location_lft BETWEEN scope.location_lft AND scope.location_rgt
    AND type_code = 'CM'
    AND date(wo_failure_time) BETWEEN :start_date AND :end_date
  ORDER BY wo_failure_time