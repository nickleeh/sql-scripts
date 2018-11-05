SELECT
    concat(wo_speciality_code
    , wo_speciality_name)                       专业
  , round(pm_on_time / pm_wo_count * 100, 2) AS '按时完成率%'
FROM
  (SELECT
     wo_speciality_code
     , wo_speciality_name
     , count(wo_id) pm_on_time
   FROM wo_history
   WHERE wo_type_type = 'PREV' AND wo_status = 8 AND wo_finish_time <= wo_history.wo_target_time
   GROUP BY wo_speciality_code) AS ontime_wo
  , (SELECT count(wo_id) pm_wo_count
     FROM wo_history
     WHERE wo_type_type = 'PREV' AND wo_status = 8) AS all_pm_wo
