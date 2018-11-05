SELECT
/* 通鼎当班时间内所接工单是否全部完成。前提：合并后统一管理，
   注：维修两班制08:00～20:00，20:00～次日08:00；45分开始交接班，由下班接单。45分属于前一个班。
 */
    CASE
      WHEN time(wo_schedule_time) > '7:45' AND time(wo_schedule_time) <= '23:59:59'
              THEN date(wo_schedule_time)
      WHEN time(wo_schedule_time) > '00:00' AND time(wo_schedule_time) <= '7:45'
              THEN date(wo_schedule_time) - INTERVAL 1 DAY
    END                 AS 日期
     , CASE
         WHEN time(wo_schedule_time) > '7:45' AND time(wo_schedule_time) <= '19:45'
                 THEN '白班'
         WHEN time(wo_schedule_time) >= '16:00' OR time(wo_schedule_time) <= '7:45'
                 THEN '晚班'
       END              AS '班次'
     , wo_id            AS 工单号
     , asset_code       AS 设备编码
     , asset_name       AS 设备名称
     , wo_name          AS 工单名称
     , employee_code    AS 负责人工号
     , employee_name    AS 负责人名字
     , CASE #
        # WO not finish
         WHEN wo_status < 6
                 THEN '否'
        # Very early this morning — belongs to yesterday's night shift.
         WHEN time(wo_schedule_time) >= '0:00' AND time(wo_schedule_time) <= '7:45' AND
              wo_finish_time > concat(date(wo_schedule_time), '-08:00')
                 THEN '否'
        # Day work.
         WHEN time(wo_schedule_time) > '7:45' AND time(wo_schedule_time) <= '19:45' AND
              wo_finish_time > concat(date(wo_schedule_time), '-20:00')
                 THEN '否'
        # Night work.
         WHEN time(wo_schedule_time) > '19:45' AND
              wo_finish_time > concat(date(wo_schedule_time) + INTERVAL 1 DAY, '-08:00')
                 THEN '否'
         ELSE '是'
       END              AS 是否当班完成
     , wo_schedule_time AS 安排时间
     , wo_finish_time   AS 完成时间
  FROM
    (SELECT wo_id
          , type_type
          , wo_schedule_time
          , wo_finish_time
          , asset_code
          , asset_model
          , asset_name
          , wo_name
          , wo_target_time
          , location_name
          , wo_status
          , status_name_cn
          , employee_code
          , employee_name
       FROM wo_list
              INNER JOIN mic_type ON wo_list.wo_type_id = mic_type.type_id
              INNER JOIN asset_list ON wo_list.wo_asset_id = asset_list.asset_id
              INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
              INNER JOIN mic_status ON wo_list.wo_status = mic_status.status_id
              LEFT JOIN admin_employee ON wo_list.wo_responsible_id = admin_employee.employee_id

     UNION ALL

     SELECT wo_id
          , wo_type_type
          , wo_schedule_time
          , wo_finish_time
          , wo_history.asset_code
          , asset_model
          , asset_list.asset_name
          , wo_name
          , wo_target_time
          , location_name
          , wo_status
          , status_name_cn
          , wo_responsible_code
          , wo_responsible_name
       FROM wo_history
              INNER JOIN asset_list ON wo_history.asset_id = asset_list.asset_id
              INNER JOIN mic_status ON wo_history.wo_status = mic_status.status_id
    ) AS all_work_order
  WHERE type_type = 'CORR'
    AND wo_schedule_time >= curdate() - INTERVAL 7 DAY
  ORDER BY wo_schedule_time