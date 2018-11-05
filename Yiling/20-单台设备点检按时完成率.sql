SELECT
    concat(asset_code, asset_name)           AS 设备
  , round(pm_on_time / pm_wo_count * 100, 2) AS '按时完成率%'
FROM
  (SELECT
     asset_code
     , asset_name
     , COUNT(wo_id) pm_on_time
   FROM wo_history
   WHERE wo_type_type = 'PREV'
         AND wo_status = 8
         AND wo_finish_time <= wo_history.wo_target_time
         AND asset_id = :asset_id) AS ontime_wo
  , (SELECT COUNT(wo_id) pm_wo_count
     FROM wo_history
     WHERE wo_type_type = 'PREV'
           AND wo_status = 8
           AND asset_id = :asset_id) AS all_pm_wo
