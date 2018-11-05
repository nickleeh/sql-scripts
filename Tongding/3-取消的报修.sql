SELECT mr_id                 AS 报修单号
     , mr_failure_time       AS 报修时间
     , asset_code            AS 设备编码
     , mr_cancel_time        AS 取消时间
     , mr_canceller          AS 取消人
     , mr_cancel_description AS 取消原因
FROM mr_cancelled