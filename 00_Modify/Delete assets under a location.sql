set @eamic_user = 'support@valueapex.com';
-- Delete assets under a location.
DELETE asset_list FROM
  (SELECT
     location_lft
     , location_rgt
   FROM asset_location
   WHERE location_id = 1412) AS T,
  asset_list
  JOIN asset_location ON asset_list.location_id = asset_location.location_id
WHERE asset_nature = 0 AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt;
--


