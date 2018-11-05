-- Part 1
SELECT wo_ff_1           AS label
     , count(asset_code) AS value
FROM (SELECT asset_code, wo_ff_1, max(wo_finish_time) AS latest_time
      FROM wo_list
             INNER JOIN asset_list ON wo_list.wo_asset_id = asset_list.asset_id
             INNER JOIN wo_freefield ON wo_list.wo_id = wo_freefield.wo_id
      GROUP BY asset_code) AS running_data
GROUP BY wo_ff_1
;

-- Part 2
SELECT asset_code     AS 设备编码
     , asset_name     AS 设备名称
     , wo_list.wo_id  AS 工单号
     , status_name_cn AS 工单状态
FROM wo_list
       INNER JOIN asset_list ON wo_list.wo_asset_id = asset_list.asset_id
       INNER JOIN wo_freefield ON wo_list.wo_id = wo_freefield.wo_id
       INNER JOIN mic_status ON wo_list.wo_status = mic_status.status_id
WHERE wo_ff_1 = :label
;
