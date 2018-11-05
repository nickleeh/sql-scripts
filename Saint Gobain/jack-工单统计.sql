SELECT
  a.wo_id                                 AS '工单号',
  a.wo_name                               AS '工单名称',
  a.wo_creation_time                      AS '创建日期',
  a.wo_schedule_time                      AS '安排时间',
  a.wo_target_time                        AS '目标完成时间',
  a.wo_finish_time                        AS '实际完成日期',
  a.asset_code                            AS '设备编码',
  a.asset_name                            AS '设备名称',
  a.location_name                         AS '位置名称',
  a.wo_type_code                          AS '工单类型',
  a.wo_failure_mode_name                  AS '故障模式',
  a.wo_failure_mechanism_subdivision_name AS '故障机制',
  a.wo_failure_cause_subdivision_name     AS '故障原因',
  a.wo_maintenance_activity_name          AS '解决办法',
  group_concat(
      t.employee_name)                    AS '维修人员',
  a.wo_feedback                           AS '维修反馈',
  a.wo_description                        AS '工单描述',
  a.wo_speciality_code                    AS '专业',
  format(a.wo_prod_losses / 60,
         0)                               AS '生产损失时间',
  IF(wo_type_type <> 'CORR',
     0,
     if(wo_downtime > 0,
        wo_downtime,
        format((time_to_sec(
                    if(timediff(a.wo_finish_time,
                                IF(a.wo_failure_time <> '0000-00-00 00:00:00',
                                   a.wo_failure_time,
                                   a.wo_creation_time)) < 0,
                       0,
                       timediff(a.wo_finish_time,
                                IF(a.wo_failure_time <> '0000-00-00 00:00:00',
                                   a.wo_failure_time,
                                   a.wo_creation_time)))
                ) / 60),
               0
        )
     )
  )                                       AS '停机时间'
FROM wo_history a
  JOIN wo_history_employee t ON t.wo_id = a.wo_id

WHERE wo_status = 8
      AND DATE(wo_creation_time) BETWEEN :start_date AND :end_date
      AND location_code IN (
  SELECT location_code
  FROM asset_location
  WHERE location_lft >= (SELECT location_lft
                         FROM asset_location
                         WHERE location_id = :location_id)
        AND location_rgt <= (SELECT location_rgt
                             FROM asset_location
                             WHERE location_id = :location_id)
)
GROUP BY a.wo_id
ORDER BY a.wo_creation_time DESC