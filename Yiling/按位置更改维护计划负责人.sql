SET
@eamic_user = 'support@valueapex.com';

/* 把维护计划的负责人，按照车间位置设置成和维修负责人一样的。 */
UPDATE
    eng_maintenance_plan
    INNER JOIN asset_list ON eng_maintenance_plan.mp_asset_id = asset_list.asset_id
    INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
    INNER JOIN (
                 SELECT
                   location_lft
                   , location_rgt
                 FROM
                   asset_location
                 WHERE
                   location_code = 'YP01'  -- 手动设定
               ) AS T
      ON
        asset_location.location_lft >= T.location_lft AND asset_location.location_lft <= T.location_rgt
SET
  eng_maintenance_plan.mp_responsible_id =
  (SELECT responsible_id
   FROM asset_location
   WHERE location_code = 'YP01') -- 手动设定