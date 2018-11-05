/*
 * Get alternative asset (asset of the same model that is neither running nor worn-out),
 * save it into asset_ff_3 in asset_list.
 * asset_ff_3: alternative asset 替代设备
 */
BEGIN
DECLARE workshop_location_id VARCHAR (100);
SET @workshop_location_id := (SELECT IF(asset_location.location_level = 4, parent_location.location_parent_id,
                                        asset_location.location_parent_id)
                              /* If location_level is 4, use its parent's location parent id, that is, the second level.
                               * Else, it's location level is 3, then use its parent location id. */
                              FROM asset_list
                                INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
                                INNER JOIN asset_location parent_location
                                  ON asset_location.location_parent_id = parent_location.location_id
                              WHERE asset_id = NEW.mr_asset_id);

UPDATE asset_list
SET asset_ff_3 = (SELECT group_concat(DISTINCT asset_code)
                  FROM

                    (SELECT
                       location_lft
                       , location_rgt
                     FROM asset_location
                     WHERE location_id = @workshop_location_id) AS T,

                    (SELECT
                       asset_code
                       , location_id
                       , asset_model
                       , asset_status
                     FROM asset_list) AS all_asset
                    INNER JOIN asset_location
                      ON all_asset.location_id = asset_location.location_id

                  WHERE asset_model = (SELECT asset_model /* Get asset model of the failure asset. */
                                       FROM (SELECT asset_model
                                             FROM asset_list
                                             WHERE asset_id = NEW.mr_asset_id) AS this_asset)
                        AND asset_status <> 3 /* not worn-out */
                        AND asset_status <> 4 /* not running */
                        AND asset_location.location_lft BETWEEN t.location_lft AND t.location_rgt)
WHERE asset_id = NEW.mr_asset_id;
END;