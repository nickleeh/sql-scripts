SELECT
    -- 20 搁置工单及原因
    wo_id                                                                   AS '工单号'
     , wo_name                                                              AS '工单名称'
     , asset_code                                                           AS '设备编码'
     , mic_failure_mechanism_subdivision.failure_mechanism_subdivision_name AS '原因'
  FROM wo_list
         LEFT JOIN mic_failure_mechanism_subdivision
           ON mic_failure_mechanism_subdivision.failure_mechanism_subdivision_id =
              wo_list.wo_failure_mechanism_subdivision_id
         LEFT JOIN asset_list ON wo_list.wo_asset_id = asset_list.asset_id
         LEFT JOIN mic_asset_class ON asset_list.asset_class_id = mic_asset_class.asset_class_id
  WHERE wo_status = 4
    AND CASE
          WHEN :asset_class_code = '' THEN TRUE
          ELSE asset_class_code = :asset_class_code END