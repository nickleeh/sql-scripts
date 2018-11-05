SET
@eamic_user = 'support@valueapex.com';


/* 把各个位置的维护负责人，设置成和车间一级的维护负责人一样。 */

UPDATE
    asset_location
    INNER JOIN (
                 SELECT
                   location_lft
                   , location_rgt
                 FROM
                   asset_location
                 WHERE
                   location_id = 498  -- 手动设定
               ) AS T
      ON
        asset_location.location_lft >= T.location_lft AND asset_location.location_lft <= T.location_rgt
SET
  asset_location.responsible_id = 18 -- 手动设定员工ID