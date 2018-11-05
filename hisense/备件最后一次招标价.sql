SELECT sp_code                       AS 备件编码
     , sp_name                       AS 备件名称
     , sp_specification              AS 规格
     , receipt_time                  AS 入库时间
     , receipt_sp_bidding_unit_price AS 招标价
  FROM sp_receipt_details
         LEFT JOIN sp_receipt ON sp_receipt_details.receipt_id = sp_receipt.receipt_id
         LEFT JOIN sp_list ON sp_receipt_details.sp_id = sp_list.sp_id
  WHERE concat(sp_code, receipt_time) IN
        (SELECT concat(sp_code, max(receipt_time)) AS sp_code_time
           FROM sp_receipt_details
                  LEFT JOIN sp_receipt ON sp_receipt_details.receipt_id = sp_receipt.receipt_id
                  LEFT JOIN sp_list ON sp_receipt_details.sp_id = sp_list.sp_id
           WHERE date(receipt_time) BETWEEN :start_date AND :end_date -- 改成形如： <= '2018-08-31'
           GROUP BY sp_code
        )
  GROUP BY sp_code
  ORDER BY sp_code
  LIMIT 1100 -- 为了防止网页崩溃。在数据库中查询时去掉。
;

-- 和上面一样，移除了数量限制，方便导出。
/* Hisense Hitachi: Get spare part biding price until :end_date */
SELECT sp_code                       AS 备件编码
     , sp_name                       AS 备件名称
     , sp_specification              AS 规格
     , receipt_time                  AS 入库时间
     , receipt_sp_bidding_unit_price AS 招标价
  FROM sp_receipt_details
         LEFT JOIN sp_receipt ON sp_receipt_details.receipt_id = sp_receipt.receipt_id
         LEFT JOIN sp_list ON sp_receipt_details.sp_id = sp_list.sp_id
  WHERE concat(sp_code, receipt_time) IN
        (SELECT concat(sp_code, max(receipt_time)) AS sp_code_time
           FROM sp_receipt_details
                  LEFT JOIN sp_receipt ON sp_receipt_details.receipt_id = sp_receipt.receipt_id
                  LEFT JOIN sp_list ON sp_receipt_details.sp_id = sp_list.sp_id
           WHERE date(receipt_time) <= :end_date
           GROUP BY sp_code
        )
  GROUP BY sp_code
  ORDER BY sp_code;

