SELECT
    asset_code                      设备编码
  , asset_name                      设备名称
  , issue_time                      时间
  , sp_issue_details.sp_id          备件编码
  , sp_name                         备件名称
  , sp_specification                规格
  , sp_issue.wo_id                  工单
  , issue_qty                       数量
  , issue_sp_unit_price             单价
  , issue_qty * issue_sp_unit_price 总金额
FROM sp_issue_details
  LEFT JOIN sp_issue ON sp_issue_details.issue_id = sp_issue.issue_id
  LEFT JOIN sp_list ON sp_issue_details.sp_id = sp_list.sp_id
  LEFT JOIN wo_history ON sp_issue.wo_id = wo_history.wo_id
WHERE wo_history.asset_id = :asset_id