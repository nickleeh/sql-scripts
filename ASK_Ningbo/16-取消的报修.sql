SELECT
    mr_id                 报修单号
  , mr_name               报修名称
  , asset_code            设备编码
  , asset_name            设备名称
  , mr_failure_time       故障时间
  , mr_description        故障描述
  , mr_priority_name      优先级
  , mr_requester          报修人
  , mr_request_time       保修时间
  , mr_updater            更新人
  , mr_last_update_time   最后更新时间
  , mr_canceller          取消人
  , mr_cancel_time        取消时间
  , mr_cancel_description 取消原因
FROM mr_cancelled
