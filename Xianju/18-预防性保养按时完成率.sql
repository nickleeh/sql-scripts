SELECT DATE_FORMAT(wo_creation_time, '%Y-%m') AS xkey
     , 100 * FORMAT(COUNT(IF(DATE(wo_target_time) >= DATE(wo_finish_time), 1, IF(
                                                                                DATE(wo_target_time) > CURDATE() AND
                                                                                wo_finish_time = '0000-00-00 00:00:00',
                                                                                1, NULL))) /
                    COUNT(wo_id), 2)          AS val
  FROM
    (SELECT location_lft
          , location_rgt
       FROM asset_location
       WHERE location_code = 'XJ'
    ) AS scope,
    (SELECT location_code
          , location_name
          , location_lft
          , location_rgt
       FROM asset_location
       WHERE location_level = 2
    ) AS department,

;
