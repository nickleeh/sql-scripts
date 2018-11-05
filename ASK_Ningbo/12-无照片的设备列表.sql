SELECT DISTINCT
  asset_code
  , asset_name
  , location_code
  , location_name
FROM
  (SELECT
     location_lft
     , location_rgt
   FROM asset_location
   WHERE location_id = if(:location_id = 0, 1, :location_id)) AS T,
  asset_list
  INNER JOIN asset_location ON asset_location.location_id = asset_list.location_id
  LEFT JOIN asset_list_picture ON asset_list_picture.asset_id_with_picture = asset_list.asset_id
WHERE asset_id_with_picture IS NULL
      AND asset_nature = 0 AND asset_status <> 9
      AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
ORDER BY asset_code ASC