-- Part 1: Numbers of each failure mode
SELECT
  wo_failure_mode_name 故障模式,
  count(wo_id)         数量
FROM wo_history
WHERE wo_failure_mode_name <> ''
GROUP BY wo_failure_mode_name
ORDER BY count(wo_id) DESC;

-- Part 2: Work orders under each failure mode
SELECT
  wo_id                工单号,
  wo_name              工单名称,
  asset_code           设备编码,
  asset_name           设备名称,
  wo_failure_mode_name 故障模式
FROM wo_history
WHERE wo_failure_mode_name = :row