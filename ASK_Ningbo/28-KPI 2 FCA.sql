--KPI 2 FCA
SELECT
    @asset_value + @moulds_value                                                            'Total amount of acquisition production equipment (Euro)'
  , this_month_sp_consumption                                                               'Consumption spare part'
  , YTD_sp_consumption                                                                      'YTD consumption spare part'

  /* YTD Value acquisition production equipment :
      Total amount of acquisition Production equipment / 12 */
  , (@asset_value + @moulds_value) / 12                                                     'YTD value acquisition production equipment'

  /* KPI 2 : % = (YTD Consumption Spare part) / (YTD Value acquisition production equipment)  */
  , concat(round(YTD_sp_consumption / ((@asset_value + @moulds_value) / 12) * 100, 2), '%') 'KPI 2'

FROM

  (SELECT
       sum(if(issue_time > DATE_FORMAT(NOW(), '%Y-%m-01'), issue_qty * issue_sp_unit_price,
              0))                                                                               this_month_sp_consumption
     , sum(if(issue_time > DATE_FORMAT(NOW(), '%Y-01-01'), issue_qty * issue_sp_unit_price, 0)) YTD_sp_consumption
   FROM
     (SELECT
        location_lft
        , location_rgt
      FROM asset_location
      WHERE location_code = 'FCA') AS T,
     sp_issue
     INNER JOIN sp_issue_details ON sp_issue.issue_id = sp_issue_details.issue_id
     INNER JOIN sp_list ON sp_issue_details.sp_id = sp_list.sp_id
     INNER JOIN wo_history ON sp_issue.wo_id = wo_history.wo_id
     INNER JOIN asset_location ON wo_history.location_code = asset_location.location_code
   WHERE issue_time >= DATE_FORMAT(NOW(), '%Y-01-01')
         and issue_status = 6
         AND sp_category_id <> 4
         AND asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt) sp_consumed,

  (SELECT @asset_value := sum(asset_acquisition_price)
   FROM
     (SELECT
        location_lft
        , location_rgt
      FROM asset_location
      WHERE location_code = 'FCA') AS T,
     asset_list
     INNER JOIN asset_location ON asset_list.location_id = asset_location.location_id
   WHERE asset_location.location_lft BETWEEN T.location_lft AND T.location_rgt
  ) assets,

  (SELECT @moulds_value := sum(sp_unit_price * sp_list.sp_current_quantity)
   FROM
     (SELECT
        location_lft
        , location_rgt
      FROM asset_location
      WHERE location_code = 'FCA') AS T,
     sp_list
     inner join asset_location on sp_list.sp_location_id = asset_location.location_id
   WHERE sp_category_id = 4
         and asset_location.location_lft between T.location_lft and T.location_rgt) moulds;