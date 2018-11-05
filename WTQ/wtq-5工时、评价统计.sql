# (1)
SELECT
  employee_name            AS '姓名',
  round(
      sum(time_to_sec(
              if(timediff(wo_finish_time, wo_start_time) < 0
                 OR (wo_start_time = 0),
                 0, timediff(wo_finish_time, wo_start_time))
          )) / 3600, 2)    AS `工时（小时）`,
  COUNT(wo_id)             AS '工单数',
  SUM(wo_confirmation = 3) AS '满意',
  SUM(wo_confirmation = 2) AS '一般',
  SUM(wo_confirmation = 1) AS '差评'
FROM
  (SELECT
     whe.employee_name,
     wo_finish_time,
     wo_start_time,
     whe.wo_id,
     wo_confirmation
   FROM (SELECT
           location_lft,
           location_rgt
         FROM asset_location
         WHERE location_id = :location_id) AS T,
     wo_history_employee whe
     LEFT JOIN wo_history ON wo_history.wo_id = whe.wo_id
     LEFT JOIN admin_employee ae ON whe.employee_code = ae.employee_code
     LEFT JOIN asset_location aloc ON ae.employee_location_id = aloc.location_id
   WHERE DATE(wo_finish_time) BETWEEN :start_date AND :end_date
         AND whe.employee_code <> "E001"
         AND wo_status = 8
         AND aloc.location_lft BETWEEN t.location_lft AND t.location_rgt
         AND whe.wo_id NOT IN (SELECT wo_id
                               FROM audit_trail_wo_status
                               WHERE new_status IN (1, 2, 3, 4))
   GROUP BY whe.wo_id, whe.employee_name
  ) aa
GROUP BY employee_name
ORDER BY `工时（小时）` DESC;

# (2)
SELECT DISTINCT
  wo_history.wo_id   '工单号',
  wo_name            '工单名称',
  CASE wo_confirmation
  WHEN 3
    THEN '满意'
  WHEN 2
    THEN '一般'
  WHEN 1
    THEN '差评'
  ELSE '未评价' END     '评价',
  wo_feedback        '反馈',
  round(time_to_sec(
            if((timediff(wo_finish_time, wo_start_time) < 0) OR (wo_start_time = 0), 0,
               timediff(wo_finish_time, wo_start_time))
        ) / 3600, 2) `工时（小时）`

FROM wo_history_employee
  INNER JOIN wo_history
    ON wo_history.wo_id = wo_history_employee.wo_id
WHERE DATE(wo_finish_time) BETWEEN :start_date AND :end_date
      AND employee_name = :row
      AND wo_status = 8
ORDER BY wo_history.wo_id DESC;