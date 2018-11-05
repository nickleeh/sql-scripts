SELECT
    mp_next_date        日期
  , production_line     生产线
  , selected_asset_code 设备编码
  , selected_asset_name 设备名称
  , task_name           任务
  , task_type AS        任务类型
  , mp_code   AS        '维护计划号/工单号'
FROM
  (SELECT
     mp_next_date
     , asset_list_2.asset_code AS production_line
     , asset_list.asset_code   AS selected_asset_code
     , asset_list.asset_name   AS selected_asset_name
     , task_name
     , '常规保养'                  AS task_type
     , mp_code
   FROM eng_maintenance_plan
     INNER JOIN eng_maintenance_plan_task ON eng_maintenance_plan.mp_id = eng_maintenance_plan_task.mp_id
     INNER JOIN asset_list ON eng_maintenance_plan_task.asset_id = asset_list.asset_id
     INNER JOIN eng_task ON eng_maintenance_plan_task.task_id = eng_task.task_id
     INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
     INNER JOIN (SELECT
                   asset_code
                   , asset_name
                   , location_id
                 FROM asset_list
                 WHERE asset_nature = 5) AS asset_list_2 ON asset_location.location_parent_id = asset_list_2.location_id
   WHERE mp_next_date BETWEEN :start_date AND :end_date
         AND location_parent_id = :location_id

   UNION ALL

   SELECT
     wo_schedule_time
     , asset_list_2.asset_code AS ProductionLine
     , asset_list.asset_code
     , asset_list.asset_name
     , task_name
     , '添加项'                   AS customized_type
     , wo_list.wo_id
   FROM wo_list
     INNER JOIN asset_list ON wo_list.wo_asset_id = asset_list.asset_id
     INNER JOIN wo_list_task ON wo_list.wo_id = wo_list_task.wo_id
     INNER JOIN eng_task ON wo_list_task.task_id = eng_task.task_id
     INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
     INNER JOIN (SELECT
                   asset_code
                   , asset_name
                   , location_id
                 FROM asset_list
                 WHERE asset_nature = 5) AS asset_list_2 ON asset_location.location_parent_id = asset_list_2.location_id
   WHERE wo_type_id = '78'
         AND wo_schedule_time BETWEEN :start_date AND :end_date
         AND location_parent_id = :location_id) AS plan
ORDER BY mp_next_date