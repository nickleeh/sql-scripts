SELECT
    -- 18 停机时间大于30分钟工单
    wo_id                                                       AS '工单号'
     , wo_name                                                  AS '工单名称'
     , wo_history.asset_code                                    AS '设备编码'
     , wo_history.asset_name                                    AS '设备名称'
     , round(timediff(wo_finish_time, wo_failure_time) / 60, 2) AS '停机时间(min)'
  FROM
    (SELECT location_lft
          , location_rgt
       FROM asset_location
       WHERE location_id = :location_id
    ) AS T,
    wo_history
      LEFT JOIN asset_list ON wo_history.asset_code = asset_list.asset_code
      JOIN asset_location ON asset_list.location_id = asset_location.location_id
  WHERE wo_type_type = 'CORR'
    AND wo_status = 8
    AND date(wo_creation_time) BETWEEN :start_date AND :end_date
    AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
    AND timediff(wo_finish_time, wo_failure_time) / 60 > 30
    AND CASE
          WHEN :asset_id = '' THEN TRUE
          ELSE wo_history.asset_id = :asset_id END
    AND CASE
          WHEN :asset_class_code = '' THEN TRUE
          ELSE asset_class_code = :asset_class_code END