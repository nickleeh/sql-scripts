USE hh7;
SELECT
  @cnt := @cnt + 1                        序号,
  asset_class_name                        类别,
  #   criticality_name                        关键性,
  asset_code                              编码,
  asset_name                              名称,
  asset_model                             规格型号,
  supplier_name                           制造单位,
  asset_manufacture_date                  出厂日期,
  concat(mp.mp_period, mp.mp_period_unit) 规定检验周期,
  mp.mp_last_finish_time                  最近一次检验时间,
  mp.mp_next_date                         下次检验时间,
  location_name                           所在位置
FROM (SELECT @cnt := 0) cnt,
  asset_list
  LEFT JOIN mic_asset_category ON asset_list.asset_category_id = mic_asset_category.asset_category_id
  LEFT JOIN mic_asset_class ON asset_list.asset_class_id = mic_asset_class.asset_class_id
  LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
  LEFT JOIN pur_supplier ON asset_list.manufacturer_id = pur_supplier.supplier_id
  LEFT JOIN mic_criticality ON asset_list.criticality_id = mic_criticality.criticality_id
  LEFT JOIN (SELECT *
             FROM eng_maintenance_plan
             WHERE mp_type_id = 7) mp ON asset_list.asset_id = mp.mp_asset_id
WHERE asset_category_code = 'YY' AND asset_list.criticality_id = 'A'
ORDER BY asset_list.criticality_id;