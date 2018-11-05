-- Maggie
SELECT
    wo_creation_time             日期
  , employee_name                姓名
  , concat(asset_id, asset_name) '设备名称/工作区域'
  , location_name                部门区域
  , mr_ff_1                      使用人
  , wo_name                      '故障/工作内容'
  , wo_failure_mode_name         '工程分析'
  , concat(issue_code, sp_name)  更换零件
  , issue_qty                    更换零件数量
  , wo_ff_1 + wo_ff_2            工作时间
  , wo_ff_1                      工程维修时间
  , wo_ff_2                      清场时间
  , wo_feedback                  反馈
FROM wo_history
  LEFT JOIN wo_history_employee ON wo_history.wo_id = wo_history_employee.wo_id
  LEFT JOIN sp_issue ON wo_history.wo_id = sp_issue.wo_id
  LEFT JOIN sp_issue_details ON sp_issue.issue_id = sp_issue_details.issue_id
  LEFT JOIN sp_list ON sp_issue_details.sp_id = sp_list.sp_id
  LEFT JOIN wo_freefield ON wo_history.wo_id = wo_freefield.wo_id;