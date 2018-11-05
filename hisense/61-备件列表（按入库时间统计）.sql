SELECT
    sp_code                       备件编码
  , sp_name                       备件名称
  , sp_specification              规格
  , receipt_time                  入库时间
  , receipt_sp_bidding_unit_price 招标价
FROM sp_receipt_details
  LEFT JOIN sp_receipt ON sp_receipt_details.receipt_id = sp_receipt.receipt_id
  LEFT JOIN sp_list ON sp_receipt_details.sp_id = sp_list.sp_id
WHERE
  concat(sp_code, receipt_time) IN
  (SELECT concat(sp_code
  , max(receipt_time)) sp_code_time
   FROM sp_receipt_details
     LEFT JOIN sp_receipt ON sp_receipt_details.receipt_id = sp_receipt.receipt_id
     LEFT JOIN sp_list ON sp_receipt_details.sp_id = sp_list.sp_id
   WHERE receipt_time BETWEEN :start_date AND :end_date
   GROUP BY sp_code)
GROUP BY sp_code
ORDER BY sp_code
LIMIT 5000;