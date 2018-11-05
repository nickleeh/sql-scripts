SET
@eamic_user = 'support@valueapex.com';

INSERT INTO eng_document_asset (document_id, asset_id)
  SELECT
    56 AS doc_id
    , asset_id
  FROM
    asset_list
  WHERE
    LEFT(asset_code, 5) = '0000-' AND asset_code LIKE '%A' -- 过滤掉 0000-26A.32 这样的设备
    AND SUBSTRING(asset_code, 6, 2) BETWEEN 26 AND 99