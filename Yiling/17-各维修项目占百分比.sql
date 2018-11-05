SELECT
    category                               AS xkey
  , round(wo_count / total_cm_wo * 100, 2) AS value
FROM
  (SELECT
       concat(asset_category_code, ' ', asset_category_name) AS category
     , count(wo_id)                                             wo_count
   FROM wo_history
   WHERE wo_type_code = 'CM'
   GROUP BY asset_category_code) cm_wo,
  (SELECT COUNT(wo_id) total_cm_wo
   FROM wo_history
   WHERE wo_type_code = 'CM') AS all_wo
ORDER BY wo_count DESC