
-- ASK Project
-- Response time: from MR time to validate time.
SELECT *
FROM
  (SELECT
       mr_list.mr_id                               报修单号
     , mr_requester                                报修人
     , mr_name                                     报修名称
     , mr_request_time                             报修时间
     , wo_creator                                  处理人
     , wo_creation_time                            处理时间
     , wo_id                                       '工单号/取消原因'
     , timediff(wo_creation_time, mr_request_time) 响应时间
   FROM wo_list
     INNER JOIN mic_type ON wo_list.wo_type_id = mic_type.type_id
     INNER JOIN mr_list ON wo_list.mr_id = mr_list.mr_id
   WHERE type_code = 'CM'
         AND mr_request_time BETWEEN :start_date AND concat(:end_date, ' 23:59')

   UNION ALL

   SELECT
     mr_id
     , mr_requester
     , mr_name
     , mr_request_time
     , mr_canceller
     , mr_cancel_time
     , mr_cancel_description
     , timediff(mr_cancel_time, mr_request_time)
   FROM mr_cancelled
   WHERE mr_request_time BETWEEN :start_date AND concat(:end_date, ' 23:59')) AS all_mr
ORDER BY 响应时间 DESC