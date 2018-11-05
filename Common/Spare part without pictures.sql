-- spare part without pictures.
SELECT
  sp_code
  , sp_name
FROM sp_list
  LEFT JOIN sp_list_picture ON sp_list_picture.sp_id_with_picture = sp_list.sp_id
WHERE sp_id_with_picture IS NULL
ORDER BY sp_code ASC;