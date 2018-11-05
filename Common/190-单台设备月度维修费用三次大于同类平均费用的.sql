-- [190 单台设备月度维修费用三次大于同类平均费用的]
-- Part 1
SELECT
  asset_code                    设备编码,
  asset_name                    设备名称,
  each_asset_cost.location_code 位置编码,
  location_name                 位置名称
FROM
  (SELECT
     asset_code,
     asset_name,
     location_code,
     location_name,
     asset_type_code,
     left(wo_finish_time, 7)                                                   each_month,
     (sum(wo_external_cost) + sum(wo_manpower_cost) + sum(wo_spare_part_cost)) single_asset_cost
   FROM wo_history
   GROUP BY asset_code, YEAR(wo_finish_time), MONTH(wo_finish_time)) each_asset_cost

  LEFT JOIN

  (SELECT
     location_code,
     asset_type_code,
     left(wo_finish_time, 7)        eachmonth,
     ((sum(wo_external_cost) + sum(wo_manpower_cost) + sum(wo_spare_part_cost))
      / count(DISTINCT asset_code)) averagecost
   FROM wo_history
   GROUP BY location_code, asset_type_code, YEAR(wo_finish_time), MONTH(wo_finish_time)) averagecost
    ON each_asset_cost.location_code = averagecost.location_code AND
       each_asset_cost.asset_type_code = averagecost.asset_type_code AND
       each_asset_cost.each_month = averagecost.eachmonth
WHERE single_asset_cost > averagecost AND each_asset_cost.each_month <> '0000-00'
GROUP BY asset_code
HAVING count(each_asset_cost.each_month) >= 2;

-- Part 2
SELECT
  asset_code             设备编码,
  asset_name             设备名称,
  eachcost.location_code 位置编码,
  location_name          位置名称,
  eachcost.each_month    月份,
  single_asset_cost      维修费用
FROM
  (SELECT
     asset_code,
     asset_name,
     location_code,
     location_name,
     asset_type_code,
     left(wo_finish_time, 7)                                                   each_month,
     (sum(wo_external_cost) + sum(wo_manpower_cost) + sum(wo_spare_part_cost)) single_asset_cost
   FROM wo_history
   GROUP BY asset_code, YEAR(wo_finish_time), MONTH(wo_finish_time)) eachcost

  LEFT JOIN

  (SELECT
     location_code,
     asset_type_code,
     left(wo_finish_time, 7)        eachmonth,
     ((sum(wo_external_cost) + sum(wo_manpower_cost) + sum(wo_spare_part_cost))
      / count(DISTINCT asset_code)) averagecost
   FROM wo_history
   GROUP BY location_code, asset_type_code, YEAR(wo_finish_time), MONTH(wo_finish_time)) average_cost
    ON eachcost.location_code = average_cost.location_code AND
       eachcost.asset_type_code = average_cost.asset_type_code AND
       eachcost.each_month = average_cost.eachmonth
WHERE single_asset_cost > averagecost AND asset_code = :row AND eachcost.each_month <> '0000-00'
ORDER BY each_month;