-- 预防性保养按时完成率（点巡检+润滑）
SELECT round(finished_ontime.finished_ontime_wo / all_finished.all_wo * 100, 2) '预防性保养按时完成率%'
FROM
  (SELECT count(wo_id) finished_ontime_wo
   FROM wo_history
   WHERE wo_type_code IN ('LUB', 'INSP')
         AND day(wo_finish_time) <= day(wo_target_time)
         AND wo_status = 8
         AND wo_schedule_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)) finished_ontime,
  (SELECT COUNT(wo_id) all_wo
   FROM wo_history
   WHERE wo_type_code IN ('LUB', 'INSP')
         AND wo_status = 8
         AND wo_schedule_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)) all_finished;