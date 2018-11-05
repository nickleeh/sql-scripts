SELECT
    asset_line                                                                 AS 位置
  , type_name                                                                  AS 工单类型
  , SUM(IF(wo_status >= 6, 1, 0))                                              AS '完成数'
  , count(wo_id)                                                               AS '当日工单数'
  , concat(format(SUM(IF(wo_status >= 6, 1, 0)) / count(wo_id) * 100, 2), '%') AS '完成比例'
FROM
  (SELECT
     wo_id
     -- take the first part of asset_code as line. LN-ZGJ01, LN is the line.
     , LEFT(asset_code, locate('-', asset_code) - 1) AS asset_line
     , wo_status
     , type_name
   FROM
     wo_list
     INNER JOIN mic_type ON wo_list.wo_type_id = mic_type.type_id
     INNER JOIN asset_list ON wo_list.wo_asset_id = asset_list.asset_id
   WHERE (type_code = 'INS' OR type_code = 'PAT')
         AND wo_schedule_time BETWEEN concat(:start_date, ' 00:00') AND concat(:end_date, ' 23:59')) pm_wo_data
GROUP BY asset_line, type_name

--
SELECT
    wo_id          工单号
  , wo_name        工单名称
  , asset_code     设备编码
  , asset_name     设备名称
  , status_name_cn 工单状态
FROM wo_list
  INNER JOIN mic_type ON wo_list.wo_type_id = mic_type.type_id
  INNER JOIN asset_list ON wo_list.wo_asset_id = asset_list.asset_id
  INNER JOIN mic_status ON wo_status = mic_status.status_id
WHERE (type_code = 'INS' OR type_code = 'PAT')
      AND wo_schedule_time BETWEEN concat(:start_date, ' 00:00') AND concat(:end_date, ' 23:59')
      AND LEFT(asset_code, locate('-', asset_code) - 1) = :row