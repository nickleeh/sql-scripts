SELECT
  @cnt := @cnt + 1                        序号,
  asset_class_name                        类别,
  asset_code                              编码,
  asset_name                              名称,
  asset_model                             型号,
  supplier_name                           制造单位,
  asset_manufacture_date                  出厂日期,
  characteristic1.characteristic_value    合格证号,
  characteristic8.characteristic_value    安装单位,
  asset_service_start_date                投用日期,
  characteristic15.characteristic_value   `使用（登记）证号`,
  characteristic22.characteristic_value   `注册编号`,
  characteristic29.characteristic_value   `规定使用期限`,
  characteristic29.characteristic_value   已用年限,
  characteristic43.characteristic_value   检测单位,
  concat(mp.mp_period, mp.mp_period_unit) 规定检验周期,
  mp.mp_last_finish_time                  最近一次检验时间,
  mp.mp_next_date                         下次检验时间,
  characteristic50.characteristic_value   使用证有效期,
  location_name                           所在位置
FROM
  (SELECT @cnt := 0) cnt,
  asset_list
  LEFT JOIN mic_asset_category ON asset_list.asset_category_id = mic_asset_category.asset_category_id
  LEFT JOIN mic_asset_class ON asset_list.asset_class_id = mic_asset_class.asset_class_id
  LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
  LEFT JOIN pur_supplier ON asset_list.manufacturer_id = pur_supplier.supplier_id
  LEFT JOIN (SELECT *
             FROM asset_characteristic
             WHERE characteristic_id = 1) characteristic1
    ON asset_list.asset_id = characteristic1.asset_id
  LEFT JOIN (SELECT *
             FROM asset_characteristic
             WHERE characteristic_id = 8) characteristic8
    ON asset_list.asset_id = characteristic1.asset_id
  LEFT JOIN (SELECT *
             FROM asset_characteristic
             WHERE characteristic_id = 15) characteristic15
    ON asset_list.asset_id = characteristic1.asset_id
  LEFT JOIN (SELECT *
             FROM asset_characteristic
             WHERE characteristic_id = 22) characteristic22
    ON asset_list.asset_id = characteristic1.asset_id
  LEFT JOIN (SELECT *
             FROM asset_characteristic
             WHERE characteristic_id = 29) characteristic29
    ON asset_list.asset_id = characteristic1.asset_id
  LEFT JOIN (SELECT *
             FROM asset_characteristic
             WHERE characteristic_id = 36) characteristic36
    ON asset_list.asset_id = characteristic1.asset_id
  LEFT JOIN (SELECT *
             FROM asset_characteristic
             WHERE characteristic_id = 43) characteristic43
    ON asset_list.asset_id = characteristic1.asset_id
  LEFT JOIN (SELECT *
             FROM asset_characteristic
             WHERE characteristic_id = 50) characteristic50
    ON asset_list.asset_id = characteristic1.asset_id
  LEFT JOIN (SELECT *
             FROM eng_maintenance_plan
             WHERE mp_type_id = 7) mp ON asset_list.asset_id = mp.mp_asset_id
WHERE asset_category_code = 'TZ';

