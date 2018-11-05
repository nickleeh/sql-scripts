SELECT
 出库单号,
 时间,
 concat('SP', right(concat('0000', 备件号),5)) 备件号,
 sp_name 备件名称,
 sp_specification 备件规格,
 数量,
 价格,
 金额,
 审批人,
 成本中心,
 出库类型,
 费用去向,
 费用科目,
 用途,
 设备编码,
 设备名称,
 固定资产编号,
 领用人
FROM
 (SELECT
 -- part 1: valid spare part issues
 issue_code 出库单号,
 issue_time 时间,
 sp_id 备件号,
 issue_qty 数量,
 sid.issue_sp_unit_price 价格,
 issue_qty * issue_sp_unit_price 金额,
 issue_validator 审批人,
 si.issue_type 出库类型,
 MIC_FEE_TYPE.fee_TYPE_NAME 费用去向,
 MIC_FEE_CLASS.fee_class_NAME as '费用科目',
 issue_remarks 用途,
 cost_center_name 成本中心,
 asset_list.asset_code 设备编码,
 asset_list.asset_name 设备名称,
 asset_list.asset_alternative_code 固定资产编号,
 concat(admin_employee.employee_code, admin_employee.employee_name) 领用人
 FROM sp_issue_details sid LEFT JOIN sp_issue si ON sid.issue_id = si.issue_code
 LEFT JOIN mic_cost_center mcc ON si.issue_cost_center_id = mcc.cost_center_id
 LEFT JOIN (wo_list
 LEFT JOIN asset_list ON asset_list.asset_id = wo_list.wo_Asset_id) ON wo_list.wo_id = si.wo_id
 LEFT JOIN admin_employee ON admin_employee.employee_id = si.employee_id
 LEFT JOIN MIC_FEE_TYPE ON MIC_FEE_TYPE.fee_type_id = sid.issue_fee_type
 INNER JOIN MIC_FEE_CLASS ON MIC_FEE_CLASS.fee_class_id=sid.ISSUE_FEE_CLASS


 WHERE issue_status = 6 AND issue_time BETWEEN concat(:start_date, ' 00:00') AND concat(:end_date, ' 23:59')

 UNION ALL

 SELECT
 -- part 2: spare parts returned (with quantity in negative number)
 ret.issue_id 出库单号,
 return_time 时间,
 retd.sp_id 备件号,
 return_qty * -1 数量,
 issue_sp_unit_price 价格,
 return_qty * -1 * issue_sp_unit_price 金额,
 NULL,
 NULL,
 NULL,
 NULL,
 NULL,
 NULL,
 NULL,
 NULL,
 null,
 NULL
 FROM sp_return_details retd
 JOIN sp_return ret ON retd.return_id = ret.return_id
 JOIN sp_issue_details ON sp_issue_details.issue_details_id = retd.line_issue_details_id
 WHERE return_status = 6 AND return_time BETWEEN concat(:start_date, ' 00:00') AND concat(:end_date, ' 23:59')) issued
 JOIN sp_list ON issued.备件号 = sp_list.sp_id
ORDER BY 时间;