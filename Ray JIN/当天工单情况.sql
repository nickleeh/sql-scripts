-- 金磊 当天的工单情况
SELECT
    wo_id          AS 工单号
  , wo_name        AS 名称
  , type_name      AS 工单类别
  , employee_name  AS 负责人
  , status_name_cn AS 工单状态
FROM wo_list
  INNER JOIN mic_status ON wo_list.wo_status = mic_status.status_id
  INNER JOIN mic_type ON wo_list.wo_type_id = mic_type.type_id
  INNER JOIN admin_employee ON wo_list.wo_responsible_id = admin_employee.employee_id
WHERE date(wo_creation_time) = curdate()

UNION ALL

SELECT
    wo_id               AS 工单号
  , wo_name             AS 名称
  , wo_type_name        AS 工单类别
  , wo_responsible_name AS 负责人
  , status_name_cn      AS 工单状态
FROM wo_history
  INNER JOIN mic_status ON wo_history.wo_status = mic_status.status_id
WHERE date(wo_creation_time) = curdate();

--
-- 金磊写的 当天的工单情况
SELECT
    location_name    AS 位置
  , wo_list.wo_id    AS 工单号
  , wo_name          AS 名称
  , type_name        AS 工单类别
  , employee_name    AS 负责人
  , status_name_cn   AS 工单状态
  , wo_schedule_time AS 安排時間
  , wo_finish_time   AS 完成时间
  , b.employee_name  AS 员工
FROM wo_list
  INNER JOIN mic_status ON wo_list.wo_status = mic_status.status_id
  INNER JOIN mic_type ON wo_list.wo_type_id = mic_type.type_id
  LEFT JOIN wo_list_employee c
    ON c.wo_id = wo_list.wo_id
  INNER JOIN admin_employee b
    ON b.employee_id = c.employee_id
  INNER JOIN asset_list d
    ON d.asset_id = wo_list.wo_asset_id
  INNER JOIN asset_location e
    ON e.location_id = d.location_id
WHERE date(wo_creation_time) = curdate()

UNION ALL

SELECT
    location_name       AS 位置
  , f.wo_id             AS 工单号
  , wo_name             AS 名称
  , wo_type_name        AS 工单类别
  , wo_responsible_name AS 负责人
  , status_name_cn      AS 工单状态
  , wo_schedule_time    AS 安排時間
  , wo_finish_time      AS 完成时间
  , employee_name     AS 员工
FROM wo_history f
  INNER JOIN mic_status ON f.wo_status = mic_status.status_id
  LEFT JOIN wo_history_employee c
    ON c.wo_id = f.wo_id
WHERE date(wo_creation_time) = curdate();