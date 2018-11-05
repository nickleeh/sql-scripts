-- First part
-- asset_code: 'FAN' Speaker Plant
SELECT
  /*
   * KPI 1 : % = (Total amount of spare Part) / (Total amount of acquisition Production equipment)
   * Moulds which are managed in spare part with sp_category_code = 'MJ', sp_category_id = 4,
   * should be count as equipment.
   */
    @asset_value + @moulds_value                                              AS 'Total amount of acquisition Production equipment (Euro)'
  ,
    @sp_value                                                                 AS 'Total amount of spare part "Reel" (Euro)'
  , concat(round((@sp_value / (@asset_value + @moulds_value)) * 100, 2), '%') AS 'KPI 1'
FROM

  (SELECT @asset_value := sum(asset_acquisition_price)
   FROM
     (SELECT
        location_lft
        , location_rgt
      FROM asset_location
      WHERE location_code = 'FAN') AS speaker
     , asset_list
     INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
   WHERE asset_location.location_lft BETWEEN speaker.location_lft AND speaker.location_rgt
  ) assets,

  (SELECT
     @moulds_value := sum(if(sp_category_id = 4, sp_unit_price * sp_current_quantity, 0))
     , @sp_value := sum(if(sp_category_id <> 4, sp_unit_price * sp_current_quantity, 0))
   FROM
     (SELECT
        location_lft
        , location_rgt
      FROM asset_location
      WHERE location_code = 'FAN') AS speaker,
     sp_list
     INNER JOIN asset_location ON sp_list.sp_location_id = asset_location.location_id
   WHERE asset_location.location_lft BETWEEN speaker.location_lft AND speaker.location_rgt
  ) moulds_and_spare_part;

-- Second part
-- asset_code: 'FCA' Transmission Plant
SELECT
  /*
   * KPI 1 : % = (Total amount of spare Part) / (Total amount of acquisition Production equipment)
   * Moulds which are managed in spare part with sp_category_code = 'MJ', sp_category_id = 4,
   * should be count as equipment.
   */
    @asset_value + @moulds_value                                              AS 'Total amount of acquisition Production equipment (Euro)'
  ,
    @sp_value                                                                 AS 'Total amount of spare part "Reel" (Euro)'
  , concat(round((@sp_value / (@asset_value + @moulds_value)) * 100, 2), '%') AS 'KPI 1'
FROM

  (SELECT @asset_value := sum(asset_acquisition_price)
   FROM
     (SELECT
        location_lft
        , location_rgt
      FROM asset_location
      WHERE location_code = 'FCA') AS transmission
     , asset_list
     INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
   WHERE asset_location.location_lft BETWEEN transmission.location_lft AND transmission.location_rgt
  ) assets,

  (SELECT
     @moulds_value := sum(if(sp_category_id = 4, sp_unit_price * sp_current_quantity, 0))
     , @sp_value := sum(if(sp_category_id <> 4, sp_unit_price * sp_current_quantity, 0))
   FROM
     (SELECT
        location_lft
        , location_rgt
      FROM asset_location
      WHERE location_code = 'FCA') AS transmission,
     sp_list
     INNER JOIN asset_location ON sp_list.sp_location_id = asset_location.location_id
   WHERE asset_location.location_lft BETWEEN transmission.location_lft AND transmission.location_rgt
  ) moulds_and_spare_part



