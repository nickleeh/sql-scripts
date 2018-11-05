SELECT /* Part 1*/
    admin_calendar.calendar_shift
     , sum(if(wo_finish_time <> 0 AND wo_finish_time <= wo_target_time, 1, 0)) /* If there's no finish time,
     it is not finished on time. */                                         AS 按时完成
     , sum(if(wo_finish_time = 0 OR wo_finish_time > wo_target_time, 1, 0)) AS 延迟
     , count(wo_id)                                                         AS 总维修工单数
     , round(sum(if(wo_finish_time <= wo_target_time, 1, 0)) / count(wo_id) * 100,
             2)                                                             AS '按时完成率%'
FROM (SELECT concat(calendar_date, " ", shift) AS calendar_shift
      FROM admin_calendar
             CROSS JOIN (SELECT 'A' AS shift
                         UNION SELECT 'B') AS shift) AS admin_calendar
       LEFT JOIN (SELECT wo_id
                       , wo_status
                       , wo_finish_time
                       , wo_target_time
                       , type_code
                       , CASE
                           WHEN HOUR(wo_failure_time) < 8
                                   THEN concat(DATE(wo_failure_time) - INTERVAL 1 DAY, " B")
                           WHEN HOUR(wo_failure_time) > 20
                                   THEN concat(DATE(wo_failure_time), " B")
                           ELSE concat(DATE(wo_failure_time), " A")
                             END AS work_shift
                  FROM
                    (SELECT wo_id
                          , wo_status
                          , wo_failure_time
                          , wo_finish_time
                          , wo_target_time
                          , type_code
                     FROM wo_list
                            INNER JOIN mic_type ON wo_list.wo_type_id = mic_type.type_id
                     WHERE type_code = 'CM'

                     UNION ALL SELECT wo_id
                                    , wo_status
                                    , wo_failure_time
                                    , wo_finish_time
                                    , wo_target_time
                                    , wo_type_code
                               FROM wo_history
                               WHERE wo_type_code = 'CM') AS wo_all) AS wo_with_shift
         ON admin_calendar.calendar_shift = wo_with_shift.work_shift
WHERE admin_calendar.calendar_shift BETWEEN '2018-08-20' AND now()
GROUP BY admin_calendar.calendar_shift

UNION ALL

SELECT '汇总'
     , sum(if(wo_finish_time <= wo_target_time, 1, 0))
     , sum(if(wo_finish_time > wo_target_time, 1, 0))
     , count(wo_id)
     , ''
FROM (SELECT concat(calendar_date, " ", shift) AS calendar_shift
      FROM admin_calendar
             CROSS JOIN (SELECT 'A' AS shift
                         UNION SELECT 'B') AS shift) AS admin_calendar
       LEFT JOIN (SELECT wo_id
                       , wo_status
                       , wo_finish_time
                       , wo_target_time
                       , type_code
                       , CASE
                           WHEN HOUR(wo_failure_time) < 8
                                   THEN concat(DATE(wo_failure_time) - INTERVAL 1 DAY, " B")
                           WHEN HOUR(wo_failure_time) > 20
                                   THEN concat(DATE(wo_failure_time), " B")
                           ELSE concat(DATE(wo_failure_time), " A")
                             END AS work_shift
                  FROM
                    (SELECT wo_id
                          , wo_status
                          , wo_failure_time
                          , wo_finish_time
                          , wo_target_time
                          , type_code
                     FROM wo_list
                            INNER JOIN mic_type ON wo_list.wo_type_id = mic_type.type_id
                     WHERE type_code = 'CM'

                     UNION ALL SELECT wo_id
                                    , wo_status
                                    , wo_failure_time
                                    , wo_finish_time
                                    , wo_target_time
                                    , wo_type_code
                               FROM wo_history
                               WHERE wo_type_code = 'CM') AS wo_all) AS wo_with_shift
         ON admin_calendar.calendar_shift = wo_with_shift.work_shift
WHERE admin_calendar.calendar_shift BETWEEN '2018-08-20' AND now()
;

-- Part 2.
SELECT *
FROM (SELECT concat(calendar_date, " ", shift) AS calendar_shift
      FROM admin_calendar
             CROSS JOIN (SELECT 'A' AS shift
                         UNION SELECT 'B') AS shift) AS admin_calendar
       LEFT JOIN (SELECT wo_id
                       , wo_status
                       , wo_finish_time
                       , wo_target_time
                       , type_code
                       , CASE
                           WHEN HOUR(wo_failure_time) < 8
                                   THEN concat(DATE(wo_failure_time) - INTERVAL 1 DAY, " B")
                           WHEN HOUR(wo_failure_time) > 20
                                   THEN concat(DATE(wo_failure_time), " B")
                           ELSE concat(DATE(wo_failure_time), " A")
                             END AS work_shift
                  FROM
                    (SELECT wo_id
                          , wo_status
                          , wo_failure_time
                          , wo_finish_time
                          , wo_target_time
                          , type_code
                     FROM wo_list
                            INNER JOIN mic_type ON wo_list.wo_type_id = mic_type.type_id
                     WHERE type_code = 'CM'

                     UNION ALL SELECT wo_id
                                    , wo_status
                                    , wo_failure_time
                                    , wo_finish_time
                                    , wo_target_time
                                    , wo_type_code
                               FROM wo_history
                               WHERE wo_type_code = 'CM') AS wo_all) AS wo_with_shift
         ON admin_calendar.calendar_shift = wo_with_shift.work_shift
WHERE admin_calendar.calendar_shift BETWEEN '2018-08-20' AND now()
  AND ((work_shift = :ROW) OR (:ROW = '汇总' AND DATE(LEFT(work_shift, 10)) BETWEEN '2018-08-20' AND now()))
  AND ((:col = '延迟' AND (wo_finish_time = 0 OR wo_finish_time > wo_target_time))
         OR (:col = '按时完成' AND wo_finish_time <> 0 AND wo_finish_time <= wo_target_time))