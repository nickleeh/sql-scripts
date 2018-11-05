SET
@eamic_user = 'support@valueapex.com';

UPDATE
    eng_maintenance_plan
    INNER JOIN asset_list ON eng_maintenance_plan.mp_asset_id = asset_list.asset_id
    INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
    INNER JOIN (SELECT
                  location_lft
                  , location_rgt
                FROM asset_location
                WHERE location_code = '01') AS T  -- 手动设定
      ON asset_location.location_lft >= T.location_lft AND asset_location.location_lft <= T.location_rgt

SET
eng_maintenance_plan.mp_responsible_id =
(SELECT employee_id
 FROM admin_employee
 WHERE employee_code = '06012') -- 手动设定;
WHERE mp_name LIKE '%操作工%'
-- LIMIT 10
