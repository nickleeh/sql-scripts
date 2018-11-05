SELECT SUM(nb_prev_wo_delayed) AS q
     , SUM(nb_prev_wo)         AS d
  FROM
    (SELECT COUNT(IF(DATE(wo_target_time) < DATE(wo_finish_time), 1,
                     IF(DATE(wo_target_time) < CURDATE() AND wo_finish_time = '0000-00-00 00:00:00',
                        1, NULL))) AS nb_prev_wo_delayed
          , COUNT(wo_id)           AS nb_prev_wo
       FROM wo_list
              INNER JOIN asset_list ON wo_list.wo_asset_id = asset_list.asset_id
              INNER JOIN asset_location ON asset_location.location_id = asset_list.location_id
              INNER JOIN
                (SELECT location_lft
                      , location_rgt
                   FROM admin_employee_location
                          NATURAL JOIN asset_location
                   WHERE employee_id = :employee_id
                 UNION ALL SELECT location_lft
                                , location_rgt
                             FROM admin_employee
                                    INNER JOIN asset_location ON location_id = employee_location_id
                             WHERE employee_id = :employee_id
                ) scope
              LEFT JOIN mic_type ON mic_type.type_id = wo_list.wo_type_id
       WHERE type_type = 'PREV'
         AND DATE(wo_schedule_time) BETWEEN DATE_FORMAT(NOW(), '%Y-%m-01') AND DATE(NOW())
         AND (wo_speciality_id = :employee_speciality_id OR :employee_speciality_id = 0 OR
              wo_speciality_id IN
              (SELECT speciality_id
                 FROM admin_employee_speciality
                 WHERE employee_id = :employee_id
              ))
         AND scope.location_lft <= asset_location.location_lft
         AND scope.location_rgt >= asset_location.location_rgt

     UNION ALL

     SELECT COUNT(IF(DATE(wo_target_time) < DATE(wo_finish_time), 1,
                     IF(DATE(wo_target_time) < CURDATE() AND wo_finish_time = '0000-00-00 00:00:00',
                        1, NULL))) AS nb_prev_wo_delayed
          , COUNT(wo_id)           AS nb_prev_wo
       FROM wo_history
              INNER JOIN mic_speciality ON speciality_code = wo_speciality_code
       WHERE wo_type_type = 'PREV'
         AND DATE(wo_schedule_time) BETWEEN DATE_FORMAT(NOW(), '%Y-%m-01') AND DATE(NOW())
         AND (speciality_id = :employee_speciality_id OR :employee_speciality_id = 0 OR
              speciality_id IN
              (SELECT speciality_id
                 FROM admin_employee_speciality
                 WHERE employee_id = :employee_id
              ))
         AND wo_status = 8
         AND location_code IN
             (SELECT location_code
                FROM asset_location
                       INNER JOIN
                         (SELECT location_lft
                               , location_rgt
                            FROM admin_employee_location
                                   NATURAL JOIN asset_location
                            WHERE employee_id = :employee_id
                          UNION ALL SELECT location_lft
                                         , location_rgt
                                      FROM admin_employee
                                             INNER JOIN asset_location
                                               ON location_id = employee_location_id
                                      WHERE employee_id = :employee_id
                         ) scope
                WHERE scope.location_lft <= asset_location.location_lft
                  AND scope.location_rgt >= asset_location.location_rgt
             )
    ) AS t