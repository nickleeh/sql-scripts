SELECT
  '原液一'                                AS xkey,
  count(wo_id)                         AS '总工单数',
  sum(IF(wo_type_code = 'BWH', 1, 0))  AS '不完好',
  sum(IF(wo_type_code = 'CM', 1, 0))   AS '维修',
  sum(IF(wo_type_code = 'PM', 1, 0))   AS '润滑保养',
  sum(IF(wo_type_code = 'INSP', 1, 0)) AS '巡检',
  sum(IF(wo_type_code = 'AQM', 1, 0))  AS '安全设施',
  sum(IF(wo_type_code = 'NJ', 1, 0))   AS '强制检测',
  sum(IF(wo_type_code = 'DT', 1, 0))   AS '倒台',
  sum(IF(wo_type_code = 'CL', 1, 0))   AS '工艺清理',
  sum(IF(wo_type_code = 'MI', 1, 0))   AS '维护改进'
FROM
  (SELECT
     wo_id,
     type_code AS 'wo_type_code'
   FROM wo_list a
     LEFT JOIN asset_list b ON a.wo_asset_id = b.asset_id
     LEFT JOIN asset_location c ON c.location_id = b.location_id
     LEFT JOIN mic_type d ON d.type_id = a.wo_type_id
   WHERE c.location_code = '18'
         AND wo_creation_time BETWEEN :start_date AND :end_date
   UNION ALL
   SELECT
     wo_id,
     wo_type_code AS 'wo_type_code'
   FROM wo_history
   WHERE location_code = '18'
         AND wo_status = '8'
         AND wo_creation_time BETWEEN :start_date AND :end_date
  ) a

UNION ALL

SELECT
  '原液二'                                AS xkey,
  count(wo_id)                         AS '总工单数',
  sum(IF(wo_type_code = 'BWH', 1, 0))  AS '不完好',
  sum(IF(wo_type_code = 'CM', 1, 0))   AS '维修',
  sum(IF(wo_type_code = 'PM', 1, 0))   AS '润滑保养',
  sum(IF(wo_type_code = 'INSP', 1, 0)) AS '巡检',
  sum(IF(wo_type_code = 'AQM', 1, 0))  AS '安全设施',
  sum(IF(wo_type_code = 'NJ', 1, 0))   AS '强制检测',
  sum(IF(wo_type_code = 'DT', 1, 0))   AS '倒台',
  sum(IF(wo_type_code = 'CL', 1, 0))   AS '工艺清理',
  sum(IF(wo_type_code = 'MI', 1, 0))   AS '维护改进'
FROM
  (SELECT
     wo_id,
     type_code AS 'wo_type_code'
   FROM wo_list a
     LEFT JOIN asset_list b ON a.wo_asset_id = b.asset_id
     LEFT JOIN asset_location c ON c.location_id = b.location_id
     LEFT JOIN mic_type d ON d.type_id = a.wo_type_id
   WHERE c.location_code = '218'
         AND wo_creation_time BETWEEN :start_date AND :end_date
   UNION ALL
   SELECT
     wo_id,
     wo_type_code AS 'wo_type_code'
   FROM wo_history
   WHERE location_code = '218'
         AND wo_status = '8'
         AND wo_creation_time BETWEEN :start_date AND :end_date
  ) b

UNION ALL

SELECT
  '酸站一'                                AS xkey,
  count(wo_id)                         AS '总工单数',
  sum(IF(wo_type_code = 'BWH', 1, 0))  AS '不完好',
  sum(IF(wo_type_code = 'CM', 1, 0))   AS '维修',
  sum(IF(wo_type_code = 'PM', 1, 0))   AS '润滑保养',
  sum(IF(wo_type_code = 'INSP', 1, 0)) AS '巡检',
  sum(IF(wo_type_code = 'AQM', 1, 0))  AS '安全设施',
  sum(IF(wo_type_code = 'NJ', 1, 0))   AS '强制检测',
  sum(IF(wo_type_code = 'DT', 1, 0))   AS '倒台',
  sum(IF(wo_type_code = 'CL', 1, 0))   AS '工艺清理',
  sum(IF(wo_type_code = 'MI', 1, 0))   AS '维护改进'
FROM
  (SELECT
     wo_id,
     type_code AS 'wo_type_code'
   FROM wo_list a
     LEFT JOIN asset_list b ON a.wo_asset_id = b.asset_id
     LEFT JOIN asset_location c ON c.location_id = b.location_id
     LEFT JOIN mic_type d ON d.type_id = a.wo_type_id
   WHERE c.location_code = '16'
         AND wo_creation_time BETWEEN :start_date AND :end_date
   UNION ALL
   SELECT
     wo_id,
     wo_type_code AS 'wo_type_code'
   FROM wo_history
   WHERE location_code = '16'
         AND wo_status = '8'
         AND wo_creation_time BETWEEN :start_date AND :end_date
  ) c

UNION ALL

SELECT
  '酸站二'                                AS xkey,
  count(wo_id)                         AS '总工单数',
  sum(IF(wo_type_code = 'BWH', 1, 0))  AS '不完好',
  sum(IF(wo_type_code = 'CM', 1, 0))   AS '维修',
  sum(IF(wo_type_code = 'PM', 1, 0))   AS '润滑保养',
  sum(IF(wo_type_code = 'INSP', 1, 0)) AS '巡检',
  sum(IF(wo_type_code = 'AQM', 1, 0))  AS '安全设施',
  sum(IF(wo_type_code = 'NJ', 1, 0))   AS '强制检测',
  sum(IF(wo_type_code = 'DT', 1, 0))   AS '倒台',
  sum(IF(wo_type_code = 'CL', 1, 0))   AS '工艺清理',
  sum(IF(wo_type_code = 'MI', 1, 0))   AS '维护改进'
FROM
  (SELECT
     wo_id,
     type_code AS 'wo_type_code'
   FROM wo_list a
     LEFT JOIN asset_list b ON a.wo_asset_id = b.asset_id
     LEFT JOIN asset_location c ON c.location_id = b.location_id
     LEFT JOIN mic_type d ON d.type_id = a.wo_type_id
   WHERE c.location_code = '216'
         AND wo_creation_time BETWEEN :start_date AND :end_date
   UNION ALL
   SELECT
     wo_id,
     wo_type_code AS 'wo_type_code'
   FROM wo_history
   WHERE location_code = '216'
         AND wo_status = '8'
         AND wo_creation_time BETWEEN :start_date AND :end_date
  ) d

UNION ALL

SELECT
  '纺练一'                                AS xkey,
  count(wo_id)                         AS '总工单数',
  sum(IF(wo_type_code = 'BWH', 1, 0))  AS '不完好',
  sum(IF(wo_type_code = 'CM', 1, 0))   AS '维修',
  sum(IF(wo_type_code = 'PM', 1, 0))   AS '润滑保养',
  sum(IF(wo_type_code = 'INSP', 1, 0)) AS '巡检',
  sum(IF(wo_type_code = 'AQM', 1, 0))  AS '安全设施',
  sum(IF(wo_type_code = 'NJ', 1, 0))   AS '强制检测',
  sum(IF(wo_type_code = 'DT', 1, 0))   AS '倒台',
  sum(IF(wo_type_code = 'CL', 1, 0))   AS '工艺清理',
  sum(IF(wo_type_code = 'MI', 1, 0))   AS '维护改进'
FROM
  (SELECT
     wo_id,
     type_code AS 'wo_type_code'
   FROM wo_list a
     LEFT JOIN asset_list b ON a.wo_asset_id = b.asset_id
     LEFT JOIN asset_location c ON c.location_id = b.location_id
     LEFT JOIN mic_type d ON d.type_id = a.wo_type_id
   WHERE c.location_code = '19'
         AND wo_creation_time BETWEEN :start_date AND :end_date
   UNION ALL
   SELECT
     wo_id,
     wo_type_code AS 'wo_type_code'
   FROM wo_history
   WHERE location_code = '19'
         AND wo_status = '8'
         AND wo_creation_time BETWEEN :start_date AND :end_date
  ) e

UNION ALL

SELECT
  '纺练二'                                AS xkey,
  count(wo_id)                         AS '总工单数',
  sum(IF(wo_type_code = 'BWH', 1, 0))  AS '不完好',
  sum(IF(wo_type_code = 'CM', 1, 0))   AS '维修',
  sum(IF(wo_type_code = 'PM', 1, 0))   AS '润滑保养',
  sum(IF(wo_type_code = 'INSP', 1, 0)) AS '巡检',
  sum(IF(wo_type_code = 'AQM', 1, 0))  AS '安全设施',
  sum(IF(wo_type_code = 'NJ', 1, 0))   AS '强制检测',
  sum(IF(wo_type_code = 'DT', 1, 0))   AS '倒台',
  sum(IF(wo_type_code = 'CL', 1, 0))   AS '工艺清理',
  sum(IF(wo_type_code = 'MI', 1, 0))   AS '维护改进'
FROM
  (SELECT
     wo_id,
     type_code AS 'wo_type_code'
   FROM wo_list a
     LEFT JOIN asset_list b ON a.wo_asset_id = b.asset_id
     LEFT JOIN asset_location c ON c.location_id = b.location_id
     LEFT JOIN mic_type d ON d.type_id = a.wo_type_id
   WHERE c.location_code = '219'
         AND wo_creation_time BETWEEN :start_date AND :end_date
   UNION ALL
   SELECT
     wo_id,
     wo_type_code AS 'wo_type_code'
   FROM wo_history
   WHERE location_code = '219'
         AND wo_status = '8'
         AND wo_creation_time BETWEEN :start_date AND :end_date
  ) f

UNION ALL

SELECT
  '公用工程'                               AS xkey,
  count(wo_id)                         AS '总工单数',
  sum(IF(wo_type_code = 'BWH', 1, 0))  AS '不完好',
  sum(IF(wo_type_code = 'CM', 1, 0))   AS '维修',
  sum(IF(wo_type_code = 'PM', 1, 0))   AS '润滑保养',
  sum(IF(wo_type_code = 'INSP', 1, 0)) AS '巡检',
  sum(IF(wo_type_code = 'AQM', 1, 0))  AS '安全设施',
  sum(IF(wo_type_code = 'NJ', 1, 0))   AS '强制检测',
  sum(IF(wo_type_code = 'DT', 1, 0))   AS '倒台',
  sum(IF(wo_type_code = 'CL', 1, 0))   AS '工艺清理',
  sum(IF(wo_type_code = 'MI', 1, 0))   AS '维护改进'
FROM
  (SELECT
     wo_id,
     type_code AS 'wo_type_code'
   FROM wo_list a
     LEFT JOIN asset_list b ON a.wo_asset_id = b.asset_id
     LEFT JOIN asset_location c ON c.location_id = b.location_id
     LEFT JOIN mic_type d ON d.type_id = a.wo_type_id
   WHERE
     location_code IN
     ('06', '206', '17', '217', '21', '221', '20', '22', '220', '222', '223', '227', '23', '24', '25', '27', '30')
     AND wo_creation_time BETWEEN :start_date AND :end_date
   UNION ALL
   SELECT
     wo_id,
     wo_type_code AS 'wo_type_code'
   FROM wo_history
   WHERE
     location_code IN
     ('06', '206', '17', '217', '21', '221', '20', '22', '220', '222', '223', '227', '23', '24', '25', '27', '30')
     AND wo_status = 8
     AND wo_creation_time BETWEEN :start_date AND :end_date
  ) g