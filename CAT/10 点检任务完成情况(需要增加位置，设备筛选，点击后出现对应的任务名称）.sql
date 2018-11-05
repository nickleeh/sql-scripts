SELECT
-- 10 点检任务完成情况(需要增加位置，设备筛选，点击后出现对应的任务名称）
    wo_list.wo_id                          AS '工单号'
     , wo_list.wo_name                     AS '工单名称'
     , sum(if(task_result_code = 0, 1, 0)) AS '待完成任务数量'
     , sum(if(task_result_code = 2, 1, 0)) AS '解决新问题任务数量'
     , sum(if(task_result_code = 3, 1, 0)) AS '发现新问题任务数量'
     , sum(if(task_result_code = 1, 1, 0)) AS '已完成任务'
  FROM wo_list
         INNER JOIN wo_list_task ON wo_list.wo_id = wo_list_task.wo_id
  WHERE (task_result_code = 0 OR task_result_code = 2 OR task_result_code = 3)
    AND date(wo_creation_time) BETWEEN :start_date AND :end_date
    AND CASE
          WHEN :asset_id = 0 THEN TRUE
          ELSE wo_asset_id = :asset_id END

-- part 2
SELECT eng_task.task_id AS 任务号
     , task_name        AS 任务名称
     , task_details     AS 任务细节
  FROM wo_list
         INNER JOIN wo_list_task ON wo_list.wo_id = wo_list_task.wo_id
         INNER JOIN eng_task ON wo_list_task.task_id = eng_task.task_id
  WHERE date(wo_creation_time) BETWEEN :start_date AND :end_date
    AND CASE
          WHEN :asset_id = 0 THEN TRUE
          ELSE wo_asset_id = :asset_id END
    AND ((:col = '待完成任务数量' AND task_result_code = 0 AND wo_list.wo_id = :row) OR
         (:col = '解决新问题任务数量' AND task_result_code = 2 AND wo_list.wo_id = :row) OR
         (:col = '发现新问题任务数量' AND task_result_code = 3 AND wo_list.wo_id = :row))