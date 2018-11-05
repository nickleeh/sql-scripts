SET
@eamic_user = 'support@valueapex.com';
/*
 * Link doc to MP. Since doc has already linked to assets, MP has asset_id,
 * so we can insert into doc ~ mp accordingly:
 * eng_document_mp
 * eng_document_asset
 * MP -> asset_id -> doc_id.
 */

INSERT INTO eng_document_mp (document_id, mp_id)
  SELECT
      eng_document_asset.document_id asset_doc_id
    , eng_maintenance_plan.mp_id     mp_mp_id
  FROM
    eng_document_asset
    INNER JOIN eng_maintenance_plan ON eng_document_asset.asset_id = eng_maintenance_plan.mp_asset_id
    LEFT JOIN eng_document_mp ON eng_maintenance_plan.mp_id = eng_document_mp.mp_id
  WHERE
    eng_document_mp.document_id IS NULL