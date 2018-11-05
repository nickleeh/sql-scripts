SET
@eamic_user = 'support@valueapex.com';
UPDATE
    asset_list
    INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
    INNER JOIN (
                 SELECT
                   location_lft
                   , location_rgt
                 FROM
                   asset_location
                 WHERE
                   location_code = 'T'
               ) AS T
      ON
        asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
SET
  asset_name = CONCAT(asset_ff_2, ' ', asset_name)
WHERE
  asset_nature = 0