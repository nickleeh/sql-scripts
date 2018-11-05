SELECT
  sp_name                                     名称,
  sp_specification                            规格型号,
  sp_class_name                               设备类型,
  sp_unit                                     单位,
  sp_current_quantity                         数量,
  sp_ff_2                                     加权单价,
  sp_ff_2 * sp_current_quantity               金额,
  sp_category_name                            备件分类,
  sp_storage_bin                              库位,
  receipt_time                                入库时间,
  supplier_name                               供应商名称,
  @zq := datediff(curdate(), receipt_time) AS 账期,
  CASE WHEN @zq < 30
    THEN '30天以内'
  WHEN @zq >= 30 AND @zq < 90
    THEN '30~90天'
  WHEN @zq >= 90 AND @zq < 180
    THEN '90~180天'
  WHEN @zq >= 180 AND @zq < 365
    THEN '180~365天'
  WHEN @zq >= 365 AND @zq < 1000
    THEN '365~1000天'
  ELSE '1000天以上' END                          账期分类
FROM sp_list sl

  LEFT JOIN

  (SELECT
     sp_id,
     supplier_name,
     max(receipt_time) AS receipt_time
   FROM sp_receipt sr
     INNER JOIN sp_receipt_details srd ON sr.receipt_id = srd.receipt_id
     INNER JOIN pur_supplier ps ON sr.supplier_id = ps.supplier_id

   GROUP BY sp_id) AS rec
    ON sl.sp_id = rec.sp_id

  LEFT JOIN mic_sp_category msc ON sl.sp_category_id = msc.sp_category_id
  LEFT JOIN mic_sp_class spcls ON sl.sp_class_id = spcls.sp_class_id

WHERE sp_current_quantity <> 0;