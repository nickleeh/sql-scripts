SELECT
/* 设备档案完好率。
设备工单（零星工单除外）未转交下一步或未完成检修，是否能做成相应设备相关联，工单没有完成则该台设备为不完好，完好率则达不到100%；
设备工单没有确认则视为该台设备检修档案不完整，同时在主界面显示设备档案完好率，可通过部门数据实时反映当月该部门设备管理状态; */
    location_code                      AS 位置
     , asset_code                      AS 设备编码
     , asset_name                      AS 设备名称
     , if(sum(wo_id) > 0, '不完好', '完好') AS 是否完好
  FROM
    /* Scope. */
      (SELECT location_lft
            , location_rgt
         FROM asset_location
         WHERE location_id = :location_id
      ) AS scope,
      asset_list
        LEFT JOIN wo_list ON asset_list.asset_id = wo_list.wo_asset_id
        LEFT JOIN mic_type ON wo_list.wo_type_id = mic_type.type_id
        INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
  WHERE type_code IS NULL
     OR type_code <> 'LX' AND asset_location.location_lft BETWEEN scope.location_lft AND scope.location_rgt
  GROUP BY asset_code