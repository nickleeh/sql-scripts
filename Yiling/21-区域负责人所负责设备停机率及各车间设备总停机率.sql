SELECT
    employee_name                                                 姓名
  , halted_asset                                                  停机设备数
  , running_asset                                                 开机设备数
  , round(halted_asset / (halted_asset + running_asset) * 100, 2) 停机率
  , overall_halt_rate                                             总停机率
FROM
  (SELECT
     responsible_id
     , T.employee_code
     , T.employee_name
     , asset_code
     , sum(IF(asset_status = 1, 1, 0)) AS halted_asset
     , sum(IF(asset_status = 4, 1, 0)) AS running_asset
   FROM
     (SELECT
        asset_code
        , location_lft
        , asset_status
      FROM asset_list
        LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
      WHERE asset_nature = 0
     ) AS asset_responsible
     INNER JOIN (SELECT
                   location_id
                   , responsible_id
                   , employee_code
                   , employee_name
                   , location_lft
                   , location_rgt
                 FROM asset_location
                   INNER JOIN admin_employee
                     ON asset_location.responsible_id = admin_employee.employee_id
                 WHERE responsible_id <> 0
                ) AS T
       ON T.location_lft < asset_responsible.location_lft AND asset_responsible.location_lft < T.location_rgt
   GROUP BY T.responsible_id
  ) AS processing_data,

  (SELECT round(halted_asset / (halted_asset + running_asset) * 100, 2) AS overall_halt_rate
   FROM
     (SELECT
          sum(if(asset_status = 1, 1, 0)) AS halted_asset
        , sum(if(asset_status = 4, 1, 0)) AS running_asset
      FROM asset_list) AS assets
  ) AS overall