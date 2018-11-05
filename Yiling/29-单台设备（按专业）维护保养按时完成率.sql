SELECT
    concat(ontime_wo.asset_code, asset_name)                           AS 设备
  , concat(ontime_wo.wo_speciality_code, ontime_wo.wo_speciality_name) AS 专业
  , round(pm_on_time / pm_wo_count * 100, 2)                           AS '按时完成率%'
FROM
  (SELECT
     asset_code
     , asset_name
     , wo_speciality_code
     , wo_speciality_name
     , COUNT(wo_id) pm_on_time
   FROM wo_history
   WHERE wo_type_type = 'PREV'
         AND wo_status = 8
         AND wo_finish_time <= wo_history.wo_target_time
         AND asset_id = :asset_id
   GROUP BY wo_speciality_code) AS ontime_wo

  INNER JOIN

  (SELECT
     asset_code
     , wo_speciality_code
     , wo_speciality_name
     , COUNT(wo_id) pm_wo_count
   FROM wo_history
   WHERE wo_type_type = 'PREV'
         AND wo_status = 8
         AND asset_id = :asset_id
   GROUP BY wo_speciality_code) AS all_pm_wo

    ON ontime_wo.asset_code = all_pm_wo.asset_code
       AND ontime_wo.wo_speciality_code = all_pm_wo.wo_speciality_code;