-- 赛科星维修类工单数统计
SELECT
    :start_date                               开始日期
  , :end_date                                 结束日期
  , archived.archived_wo + non_archived.cm_wo 维修类工单数
FROM
  (SELECT count(wo_id) archived_wo
   FROM wo_history
   WHERE wo_type_code = 'CM' AND wo_status = 8
         AND wo_schedule_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)) archived,
  (SELECT count(wo_id) cm_wo
   FROM wo_list
   WHERE wo_type_id = 1
         AND wo_schedule_time BETWEEN :start_date AND (:end_date + INTERVAL 1 DAY)) non_archived;