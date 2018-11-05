SELECT
    status_name_cn 工单状态
  , count(wo_id)   数量
FROM wo_list
  INNER JOIN mic_status ON wo_list.wo_status = mic_status.status_id
WHERE wo_creation_time BETWEEN :start_date AND :end_date
GROUP BY status_name_cn

UNION ALL

SELECT
  '总计'
  , count(wo_id) 数量
FROM wo_list
  INNER JOIN mic_status ON wo_list.wo_status = mic_status.status_id
WHERE wo_creation_time BETWEEN :start_date AND :end_date