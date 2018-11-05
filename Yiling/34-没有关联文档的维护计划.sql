SELECT
    mp_code 维护计划编码
  , mp_name 维护计划名称
FROM eng_maintenance_plan
  LEFT JOIN eng_document_mp ON eng_maintenance_plan.mp_id = eng_document_mp.mp_id
WHERE document_id IS NULL