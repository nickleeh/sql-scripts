set @eamic_user= "support@valueapex.com";
update asset_list
set asset_code = concat("13-", asset_code)
WHERE asset_nature = 0;


-- Set asset_primary_code
set @eamic_user= "support@valueapex.com";
update asset_list
set asset_primary_code = asset_code
WHERE asset_nature = 0