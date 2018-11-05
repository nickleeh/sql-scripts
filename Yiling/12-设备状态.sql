-- Part 1.
SELECT
    label AS xkey
  , qty   AS '设备数量'
FROM

  (SELECT
       '报修待处理'                    label
     , @mr_qty := COUNT(mr_id) AS qty
   FROM
     (SELECT
        location_lft
        , location_rgt
      FROM asset_location
      WHERE location_id = if(:location_id = 0, 1, :location_id)) AS T,
     mr_list
     INNER JOIN asset_list ON mr_list.mr_asset_id = asset_list.asset_id
     INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
   WHERE mr_status = 0 AND asset_location.location_lft BETWEEN t.location_lft AND t.location_rgt) mr

UNION ALL

SELECT
    '维修中'                      label
  , @cm_qty := COUNT(wo_id) AS qty
FROM
  (SELECT
     location_lft
     , location_rgt
   FROM asset_location
   WHERE location_id = if(:location_id = 0, 1, :location_id)) AS T,
  wo_list
  LEFT JOIN asset_list ON wo_list.wo_asset_id = asset_list.asset_id
  LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
WHERE wo_type_id = 1 /*to be replaced with correct type_id*/
      AND wo_status < 6
      AND asset_location.location_lft BETWEEN t.location_lft AND t.location_rgt


UNION ALL

SELECT
    '试车'                          label
  , @testrun := COUNT(asset_code) qty
FROM
  (SELECT
     location_lft
     , location_rgt
   FROM asset_location
   WHERE location_id = if(:location_id = 0, 1, :location_id)) AS T,
  asset_list
  LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
WHERE asset_nature = 0 AND asset_status = 0
      AND asset_location.location_lft BETWEEN t.location_lft AND t.location_rgt


UNION ALL

SELECT
    '在用（未开机）'                     label
  , @testrun := COUNT(asset_code) qty
FROM
  (SELECT
     location_lft
     , location_rgt
   FROM asset_location
   WHERE location_id = if(:location_id = 0, 1, :location_id)) AS T,
  asset_list
  LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
WHERE asset_nature = 0 AND asset_status = 1
      AND asset_location.location_lft BETWEEN t.location_lft AND t.location_rgt


UNION ALL

SELECT
    '闲置'                            label
  , @not_inuse := COUNT(asset_code) qty
FROM
  (SELECT
     location_lft
     , location_rgt
   FROM asset_location
   WHERE location_id = if(:location_id = 0, 1, :location_id)) AS T,
  asset_list
  LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
WHERE asset_nature = 0 AND asset_status = 2
      AND asset_location.location_lft BETWEEN t.location_lft AND t.location_rgt


UNION ALL

SELECT
    '报废'                           label
  , @scrapped := COUNT(asset_code) qty
FROM
  (SELECT
     location_lft
     , location_rgt
   FROM asset_location
   WHERE location_id = if(:location_id = 0, 1, :location_id)) AS T,
  asset_list
  LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
WHERE asset_nature = 0 AND asset_status = 3
      AND asset_location.location_lft BETWEEN t.location_lft AND t.location_rgt


UNION ALL

SELECT
    '运行中'                          label
  , @scrapped := COUNT(asset_code) qty
FROM
  (SELECT
     location_lft
     , location_rgt
   FROM asset_location
   WHERE location_id = if(:location_id = 0, 1, :location_id)) AS T,
  asset_list
  LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
WHERE asset_nature = 0 AND asset_status = 4
      AND asset_location.location_lft BETWEEN t.location_lft AND t.location_rgt;

-- Part 2.
SELECT
  @cnt := @cnt + 1 AS 'No.'
  , f1
  , f2
  , f3
  , f4
  , f5
  , f6

FROM

  (SELECT @cnt := -1) AS cnt,
  (SELECT
       '1' f1
     , '2' f2
     , '3' f3
     , '4' f4
     , '5' f5
     , '6' f6
     , '7' type
   UNION ALL
   SELECT
     '报修号'
     , '报修名称'
     , '设备'
     , '位置'
     , '报修人'
     , '故障时间'
     , '报修待处理'

   UNION ALL

   SELECT
     mr_id
     , mr_name
     , concat(asset_code, ' ', asset_name)
     , concat(location_code, ' ', location_name)
     , mr_requester
     , mr_failure_time
     , '报修待处理'
   FROM
     (SELECT
        location_lft
        , location_rgt
      FROM asset_location
      WHERE location_id = if(:location_id = 0, 1, :location_id)) AS T,
     mr_list
     LEFT JOIN asset_list ON mr_list.mr_asset_id = asset_list.asset_id
     LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
   WHERE mr_status = 0
         AND asset_location.location_lft BETWEEN t.location_lft AND t.location_rgt


   UNION ALL

   SELECT
     '工单号'
     , '工单名称'
     , '设备'
     , '位置'
     , '负责人'
     , '目标完成时间'
     , '维修中'

   UNION ALL

   SELECT
     wo_id
     , wo_name
     , concat(asset_code, ' ', asset_name)
     , concat(location_code, ' ', location_name)
     , employee_name
     , wo_target_time
     , '维修中'
   FROM
     (SELECT
        location_lft
        , location_rgt
      FROM asset_location
      WHERE location_id = if(:location_id = 0, 1, :location_id)) AS T,
     wo_list
     LEFT JOIN asset_list ON wo_list.wo_asset_id = asset_list.asset_id
     LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
     LEFT JOIN admin_employee ON wo_list.wo_responsible_id = admin_employee.employee_id
   WHERE wo_type_id = 1 /*to be replaced with correct type_id*/
         AND wo_status < 6
         AND asset_location.location_lft BETWEEN t.location_lft AND t.location_rgt


   UNION ALL

   SELECT
     '设备编码'
     , '设备名称'
     , '位置编码'
     , '位置名称'
     , '型号'
     , '序列号'
     , '试车'

   UNION ALL

   SELECT
     asset_code
     , asset_name
     , location_code
     , location_name
     , asset_model
     , asset_serial_number
     , '试车'
   FROM
     (SELECT
        location_lft
        , location_rgt
      FROM asset_location
      WHERE location_id = if(:location_id = 0, 1, :location_id)) AS T,
     asset_list
     LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
   WHERE asset_nature = 0 AND asset_status = 0
         AND asset_location.location_lft BETWEEN t.location_lft AND t.location_rgt


   UNION ALL

   SELECT
     '设备编码'
     , '设备名称'
     , '位置编码'
     , '位置名称'
     , '型号'
     , '序列号'
     , '在用（未开机）'

   UNION ALL

   SELECT
     asset_code
     , asset_name
     , location_code
     , location_name
     , asset_model
     , asset_serial_number
     , '在用（未开机）'
   FROM
     (SELECT
        location_lft
        , location_rgt
      FROM asset_location
      WHERE location_id = if(:location_id = 0, 1, :location_id)) AS T,
     asset_list
     LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id
   WHERE asset_nature = 0 AND asset_status = 1
         AND asset_location.location_lft BETWEEN t.location_lft AND t.location_rgt


   UNION ALL

   SELECT
     '设备编码'
     , '设备名称'
     , '位置编码'
     , '位置名称'
     , '型号'
     , '序列号'
     , '运行中'

   UNION ALL

   SELECT
     asset_code
     , asset_name
     , location_code
     , location_name
     , asset_model
     , asset_serial_number
     , '运行中'
   FROM
     (SELECT
        location_lft
        , location_rgt
      FROM asset_location
      WHERE location_id = if(:location_id = 0, 1, :location_id)) AS T,
     asset_list
     LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id

   WHERE asset_nature = 0 AND asset_status = 4
         AND asset_location.location_lft BETWEEN t.location_lft AND t.location_rgt


   UNION ALL

   SELECT
     '设备编码'
     , '设备名称'
     , '位置编码'
     , '位置名称'
     , '型号'
     , '序列号'
     , '闲置'

   UNION ALL

   SELECT
     asset_code
     , asset_name
     , location_code
     , location_name
     , asset_model
     , asset_serial_number
     , '闲置'
   FROM
     (SELECT
        location_lft
        , location_rgt
      FROM asset_location
      WHERE location_id = if(:location_id = 0, 1, :location_id)) AS T,
     asset_list
     LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id

   WHERE asset_nature = 0 AND asset_status = 2
         AND asset_location.location_lft BETWEEN t.location_lft AND t.location_rgt

   UNION ALL

   SELECT
     '设备编码'
     , '设备名称'
     , '位置编码'
     , '位置名称'
     , '型号'
     , '序列号'
     , '报废'

   UNION ALL


   SELECT
     asset_code
     , asset_name
     , location_code
     , location_name
     , asset_model
     , asset_serial_number
     , '报废'
   FROM
     (SELECT
        location_lft
        , location_rgt
      FROM asset_location
      WHERE location_id = if(:location_id = 0, 1, :location_id)) AS T,
     asset_list
     LEFT JOIN asset_location ON asset_list.location_id = asset_location.location_id

   WHERE asset_nature = 0 AND asset_status = 3
         AND asset_location.location_lft BETWEEN t.location_lft AND t.location_rgt


  ) all_data
WHERE type = :label