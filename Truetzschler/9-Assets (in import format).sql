SELECT
  asset_code
  , asset_name
  , asset_nature
  , location_code
  , criticality_code
  , function_code
  , asset_status_code
  , asset_category_code
  , asset_class_code
  , asset_type_code
  , cost_center_code
  , pur_supplier.supplier_code     supplier_code
  , pur_manufacturer.supplier_code manufacturer_code
  , asset_model
  , asset_serial_number
  , asset_alternative_code
  , asset_useful_years
  , asset_acquisition_price
  , asset_acquisition_date
  , asset_manufacture_date
  , asset_installation_date
  , asset_service_start_date
  , asset_warranty_date
  , asset_authorisation_required
  , asset_safety_instruction
  , asset_forbidden_action
  , asset_description
  , epc_rfid
  , asset_ff_1
  , asset_ff_2
  , asset_ff_3
  , asset_ff_4
  , asset_ff_5
FROM asset_list
  LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
  LEFT JOIN mic_criticality ON asset_list.criticality_id = mic_criticality.criticality_id
  LEFT JOIN mic_function ON asset_list.function_id = mic_function.function_id
  LEFT JOIN mic_asset_status ON asset_list.asset_status = mic_asset_status.asset_status_id
  LEFT JOIN mic_asset_category ON asset_list.asset_category_id = mic_asset_category.asset_category_id
  LEFT JOIN mic_asset_class ON asset_list.asset_class_id = mic_asset_class.asset_class_id
  LEFT JOIN mic_asset_type ON asset_list.asset_type_id = mic_asset_type.asset_type_id
  LEFT JOIN mic_cost_center ON asset_list.asset_cost_center_id = mic_cost_center.cost_center_id
  LEFT JOIN pur_supplier ON asset_list.supplier_id = pur_supplier.supplier_id
  LEFT JOIN pur_supplier pur_manufacturer ON asset_list.manufacturer_id = pur_manufacturer.supplier_id
ORDER BY asset_code