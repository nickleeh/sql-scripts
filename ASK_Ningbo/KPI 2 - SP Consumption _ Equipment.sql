SELECT
    date_format(md6_ff_1 - INTERVAL 1 MONTH, '%Y-%m') AS 'Year-Month'
  , md6_ff_2                                          AS 'Total amount of acquisition production equipment (Euro)'
  , md6_ff_3                                          AS 'Consumption spare part'
  , md6_ff_4                                          AS 'YTD consumption spare part'
  , md6_ff_5                                          AS 'YTD value acquisition production equipment'
  , md6_ff_6                                          AS 'KPI 2'
  , ifnull(md6_ff_7, 'ASK')                           AS 'Plant'
FROM mic_module_6