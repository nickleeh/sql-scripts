-- Number of equipment / number of failures

SELECT
  z.xkey
  , CONCAT(FORMAT((100 - 100 * w.nb_faulty_asset / z.nb_asset), 2), '%') AS val
FROM (
       SELECT
         xkey
         , (@s := @s + t.nb_asset) AS nb_asset
       FROM (
              SELECT
                  DATE_FORMAT(asset_creation_time, '%Y-%m') AS xkey
                , COUNT(asset_id)                           AS nb_asset
              FROM asset_list
              WHERE asset_nature = 0 OR asset_nature = 1
              GROUP BY YEAR(asset_creation_time), MONTH(asset_creation_time)
              ORDER BY YEAR(asset_creation_time), MONTH(asset_creation_time)
            ) t
         JOIN (SELECT @s := 0) r
     ) z
  LEFT JOIN (
              SELECT
                  DATE_FORMAT(wo_creation_time, '%Y-%m') AS xkey
                , COUNT(DISTINCT asset_id)               AS nb_faulty_asset
              FROM wo_history
              WHERE wo_type_type = 'CORR'
                    AND wo_status = 8
              GROUP BY YEAR(wo_creation_time), MONTH(wo_creation_time)
              ORDER BY wo_creation_time ASC
            ) w ON w.xkey = z.xkey
