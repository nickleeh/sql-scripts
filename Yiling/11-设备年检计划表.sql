SELECT
    asset_code                              AS 设备编号
  , asset_name                              AS 设备名称
  , asset_model                             AS 规格型号
  , supplier_name                           AS 设备制造商
  , location_name                           AS 安装地点
  , if(month(mp_next_date) = '01', '●', '') AS `一`
  , if(month(mp_next_date) = '02', '●', '') AS '二'
  , if(month(mp_next_date) = '03', '●', '') AS '三'
  , if(month(mp_next_date) = '04', '●', '') AS '四'
  , if(month(mp_next_date) = '05', '●', '') AS '五'
  , if(month(mp_next_date) = '06', '●', '') AS '六'
  , if(month(mp_next_date) = '07', '●', '') AS '七'
  , if(month(mp_next_date) = '08', '●', '') AS '八'
  , if(month(mp_next_date) = '09', '●', '') AS '九'
  , if(month(mp_next_date) = '10', '●', '') AS '十'
  , if(month(mp_next_date) = '11', '●', '') AS '十一'
  , if(month(mp_next_date) = '12', '●', '') AS '十二'
  , '机修班'                                   AS '检修执行部门'
  , priority_code                           AS 重点级别
  , eng_maintenance_plan_freefield.mp_ff_1  AS 使用频率
  , eng_maintenance_plan_freefield.mp_ff_2  AS 维修难度
FROM eng_maintenance_plan
  INNER JOIN asset_list ON eng_maintenance_plan.mp_asset_id = asset_list.asset_id
  INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
  INNER JOIN mic_type ON eng_maintenance_plan.mp_type_id = mic_type.type_id
  INNER JOIN mic_priority ON eng_maintenance_plan.mp_priority_id = mic_priority.priority_id
  LEFT JOIN pur_supplier ON asset_list.manufacturer_id = pur_supplier.supplier_id
  LEFT JOIN eng_maintenance_plan_freefield ON eng_maintenance_plan.mp_id = eng_maintenance_plan_freefield.mp_id
WHERE type_code = 'YPM'