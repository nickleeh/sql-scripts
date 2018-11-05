SELECT
    DATE_FORMAT(md5_ff_1 - INTERVAL 1 MONTH, '%Y-%m') 'Year-Month'
  , md5_ff_2                                          'Total amount of acquisition Production equipment (Euro)'
  , md5_ff_3                                          'Total amount of spare part "Reel" (Euro)'
  , md5_ff_4                                          'KPI 1'
FROM mic_module_5