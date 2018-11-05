SELECT
    concat(asset_category_code, ' ', asset_category_name) AS xkey
  , count(wo_id)                                          AS '数量'
  , round(count(wo_id) / total_cm * 100, 2)                  百分百
FROM

  (SELECT
     asset_category_code
     , asset_category_name
     , wo_id
   FROM
     wo_history
   WHERE wo_type_code = 'CM'
   GROUP BY asset_category_code) AS categorized_cm,
  (SELECT COUNT(wo_id) total_cm
   FROM wo_history
   WHERE wo_type_code = 'CM') AS cm

ORDER BY COUNT(wo_id) DESC;