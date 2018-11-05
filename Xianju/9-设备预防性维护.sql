SELECT
    '工程设备部' AS                         '使用部门'
  , asset_name                         设备名称
  , asset_code                         固定资产编号
  , asset_model                        型号
  , mp_name                            内容
  , addtime(mp_next_date, mp_duration) 完成时间
  , location_name                      所在工序
  , '工程设备部' AS                         '负责检修部门'
  , '检修周期'  AS                         '检修或更新理由'
  , ''      AS                         '完成情况'
  , ''      AS                         '确认人和时间'
FROM eng_maintenance_plan
  INNER JOIN asset_list ON eng_maintenance_plan.mp_asset_id = asset_list.asset_id
  INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
WHERE mp_next_date BETWEEN :start_date AND :end_date
