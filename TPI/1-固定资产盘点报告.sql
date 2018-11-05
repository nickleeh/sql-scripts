SELECT
  wo_history.wo_id    工单号,
  wo_name             工单名称,
  wo_schedule_time    安排时间,
  concat(round(
             sum(if(task_result_code = 1, 1, 0)) / count(task_result_code) * 100,
             2), '%') 盘点结果
FROM wo_history
  RIGHT JOIN wo_history_task ON wo_history.wo_id = wo_history_task.wo_id
WHERE wo_type_code = 'AIT'
      AND wo_schedule_time BETWEEN :start_date AND :end_date
GROUP BY wo_history.wo_id;

--
SELECT
  @cnt := @cnt + 1           序号,
  wo_history.wo_id           工单号,
  wo_history_task.asset_code 设备编码,
  wo_history.asset_name      设备名称,
  wo_history.location_code   位置编码,
  wo_history.location_name   位置名称,
  task_result_code           盘点结果
FROM (SELECT @cnt := 0) T,
  wo_history
  RIGHT JOIN wo_history_task ON wo_history.wo_id = wo_history_task.wo_id
WHERE wo_history.wo_id = :row