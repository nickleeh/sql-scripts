SET
@eamic_user = 'support@valueapex.com';
/*
 * 因为参数的名称包含对应设备的编码，例如：PAR0001 0021-05B 真空干燥箱 运行时间
 * 所以可以把维护计划中CMB的参数，批量设置为对应的参数。
 */
UPDATE
    eng_maintenance_plan
    INNER JOIN asset_list ON eng_maintenance_plan.mp_asset_id = asset_list.asset_id
    INNER JOIN asset_parameter
      ON asset_parameter.parameter_name LIKE CONCAT('%', asset_list.asset_code, '%') /* 参数名称和设备编码匹配*/
SET
  mp_meter_id = parameter_id