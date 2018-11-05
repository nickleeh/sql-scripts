-- Part 1
SELECT /* Halt and all asset statistics. */
    all_asset_qty     AS '总数'
     , halt_asset_qty AS '停机'
FROM
  (SELECT count(asset_code) AS all_asset_qty FROM asset_list WHERE asset_nature = 0) all_asset,
  (SELECT wo_ff_1 AS label, count(asset_code) AS halt_asset_qty
   FROM (SELECT asset_code, wo_ff_1, max(wo_finish_time) AS latest_time
         FROM wo_list
                INNER JOIN asset_list ON wo_list.wo_asset_id = asset_list.asset_id
                INNER JOIN wo_freefield ON wo_list.wo_id = wo_freefield.wo_id
         WHERE wo_ff_1 = '停机'
         GROUP BY asset_code) AS running_data) AS halt_asset
;

-- Part 2
SELECT /* List all work orders on halt assets. */
    asset_code          AS 设备编码
     , asset_name       AS 设备名称
     , wo_list.wo_id    AS 工单号
     , wo_name          AS 工单名称
     , status_name_cn   AS 工单状态
     , wo_creation_time AS 创建时间
FROM wo_list
       INNER JOIN asset_list ON wo_list.wo_asset_id = asset_list.asset_id
       INNER JOIN wo_freefield ON wo_list.wo_id = wo_freefield.wo_id
       INNER JOIN mic_status ON wo_list.wo_status = mic_status.status_id
WHERE wo_ff_1 = :col
;