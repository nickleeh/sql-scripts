# 安全库存比例 = 安全库存金额 / 总金额
SELECT location_code                                AS 车间编码
     , location_name                                AS 车间名称
     , round(safe_sp_value / all_sp_value * 100, 2) AS "安全库存比例%"
  FROM
    (SELECT substring_index(sp_code, "-", 1)                                   AS factory
          , location_code
          , location_name
          , sum(coalesce(sp_unit_price, 0) * coalesce(sp_minimum_quantity, 0)) AS safe_sp_value
          , sum(coalesce(sp_unit_price, 0) * coalesce(sp_current_quantity, 0)) AS all_sp_value
       FROM sp_list
              INNER JOIN asset_location ON sp_list.sp_location_id = asset_location.location_id
       GROUP BY location_code
    ) AS sp_data

--
# （超过最高库存的备件金额 / 总备件金额）* 100%
SELECT factory                                           AS 车间
     , round(overstock_sp_value / all_sp_value * 100, 2) AS 积压百分比
  FROM
    (SELECT substring_index(sp_code, "-", 1)         AS factory
          , sum(CASE
                  WHEN sp_current_quantity > COALESCE(sp_maximum_quantity, 0)
                          THEN sp_unit_price *
                               (sp_current_quantity - COALESCE(sp_maximum_quantity, 0))
                  ELSE 0 END)                        AS overstock_sp_value
          , sum(sp_unit_price * sp_current_quantity) AS all_sp_value
       FROM sp_list
       GROUP BY substring_index(sp_code, "-", 1)
    ) AS sp_data
