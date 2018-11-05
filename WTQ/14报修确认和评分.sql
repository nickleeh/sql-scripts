-- First part
SELECT
  mr_requester                        AS '报修人员',
  COUNT(wo_id)                        AS '报修单量',
  SUM(IF(wo_confirmation = 0, 1, 0))  AS '未维修确认总数',
  SUM(IF(wo_confirmation <> 0, 1, 0)) AS '维修确认总数',
  SUM(wo_confirmation = 3)            AS '满意',
  SUM(wo_confirmation = 2)            AS '一般',
  SUM(wo_confirmation = 1)            AS '差评'
FROM
  (SELECT
     location_lft,
     location_rgt
   FROM asset_location
   WHERE location_id = :location_id) AS T,
  wo_history
  JOIN asset_location aloc ON wo_history.location_code = aloc.location_code
WHERE aloc.location_lft BETWEEN T.location_lft AND T.location_rgt AND
      DATE(wo_archive_time) BETWEEN :start_date AND :end_date
      AND wo_type_type = 'CORR'
      AND mr_id <> 0
      AND wo_status = 8
GROUP BY mr_requester



-- Second part
SELECT
  wo_id       工单号,
  wo_name     工单名称,
  CASE wo_confirmation
  WHEN 1
    THEN "差评"
  WHEN 2
    THEN "中评"
  WHEN 3
    THEN "好评"
  ELSE "" END 评价
FROM wo_history
WHERE mr_requester = :row