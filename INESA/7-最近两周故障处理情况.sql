SELECT
/* 仪电最近一周故障维修统计
   part 1.
 */
    calendar_shift                                                                       AS 班次
     , mr_validated                                                                      AS 已核准
     , mr_to_be_processed                                                                AS 未处理
     , mr_cancelled                                                                      AS 取消
     , ifnull(mr_validated, 0) + ifnull(mr_to_be_processed, 0) + ifnull(mr_cancelled, 0) AS 总报修数
FROM (SELECT concat(calendar_date, " ", shift) AS calendar_shift
      FROM admin_calendar
             NATURAL JOIN (SELECT 'A' AS shift
                           UNION SELECT 'B') AS shift) AS admin_calendar
       LEFT JOIN (SELECT work_shift
                       , sum(if(mr_status = 0, 1, 0)) AS mr_to_be_processed
                       , sum(if(mr_status = 6, 1, 0)) AS mr_validated
                  FROM
                    (SELECT mr_request_time
                          , mr_id
                          , mr_name
                          , mr_status
                          , CASE
                              WHEN hour(mr_request_time) < 8
                                      THEN concat(date(mr_request_time) - INTERVAL 1 DAY, " B")
                              WHEN hour(mr_request_time) > 20
                                      THEN concat(date(mr_request_time), " B")
                              ELSE concat(date(mr_request_time), " A")
                                END AS work_shift
                     FROM mr_list) AS mr_list_with_team
                  GROUP BY work_shift) AS mr_exists ON admin_calendar.calendar_shift = mr_exists.work_shift
       LEFT JOIN (SELECT work_shift
                       , count(mr_id) AS mr_cancelled
                  FROM
                    (SELECT mr_request_time
                          , mr_id
                          , mr_name
                          , mr_status
                          , CASE
                              WHEN hour(mr_request_time) < 8
                                      THEN concat(date(mr_request_time) - INTERVAL 1 DAY, " B")
                              WHEN hour(mr_request_time) > 20
                                      THEN concat(date(mr_request_time), " B")
                              ELSE concat(date(mr_request_time), " A")
                                END AS work_shift
                     FROM mr_cancelled) AS mr_cancelled_with_team
                  WHERE mr_status = 9
                  GROUP BY work_shift) AS mr_cancelled ON admin_calendar.calendar_shift = mr_cancelled.work_shift
WHERE date(left(calendar_shift, 10)) BETWEEN '2018-08-20' AND now()

UNION ALL

SELECT '汇总'
     , sum(if(mr_status = 6, 1, 0))
     , sum(if(mr_status = 0, 1, 0))
     , sum(if(mr_status = 9, 1, 0))
     , count(mr_id)
FROM
  (SELECT mr_request_time
        , mr_id
        , mr_name
        , mr_status
        , CASE
            WHEN hour(mr_request_time) < 8
                    THEN concat(date(mr_request_time) - INTERVAL 1 DAY, " B")
            WHEN hour(mr_request_time) > 20
                    THEN concat(date(mr_request_time), " B")
            ELSE concat(date(mr_request_time), " A")
              END AS work_shift
   FROM mr_list

   UNION ALL

   SELECT mr_request_time
        , mr_id
        , mr_name
        , mr_status
        , CASE
            WHEN hour(mr_request_time) < 8
                    THEN concat(date(mr_request_time) - INTERVAL 1 DAY, " B")
            WHEN hour(mr_request_time) > 20
                    THEN concat(date(mr_request_time), " B")
            ELSE concat(date(mr_request_time), " A")
              END AS work_shift
   FROM mr_cancelled) AS mr_all
WHERE mr_request_time BETWEEN '2018-08-20' AND now()
;

-- ---------------------------------
SELECT
/* part 2 */
    *
FROM
  (SELECT mr_request_time
        , mr_id
        , asset_code
        , mr_name
        , mr_status
        , CASE
            WHEN hour(mr_request_time) < 8
                    THEN concat(date(mr_request_time) - INTERVAL 1 DAY, " B")
            WHEN hour(mr_request_time) > 20
                    THEN concat(date(mr_request_time), " B")
            ELSE concat(date(mr_request_time), " A")
              END AS work_shift
   FROM mr_list
          INNER JOIN asset_list ON mr_list.mr_asset_id = asset_list.asset_id

   UNION ALL

   SELECT mr_request_time
        , mr_id
        , asset_code
        , mr_name
        , mr_status
        , CASE
            WHEN hour(mr_request_time) < 8
                    THEN concat(date(mr_request_time) - INTERVAL 1 DAY, " B")
            WHEN hour(mr_request_time) > 20
                    THEN concat(date(mr_request_time), " B")
            ELSE concat(date(mr_request_time), " A")
              END AS work_shift
   FROM mr_cancelled) AS mr_all
WHERE ((work_shift = :row) OR (:row = '汇总' AND date(left(work_shift, 10)) BETWEEN '2018-08-20' AND now()))
  AND ((:col = '未处理' AND mr_status < 6)
         OR (:col = '已核准' AND mr_status = 6)
         OR (:col = '取消' AND mr_status = 9))
