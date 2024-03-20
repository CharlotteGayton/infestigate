$env:DATALAKE_NAME = "infstorageaccount"
$env:DATALAKE_RESOURCE_GROUP_NAME = "infestigate-storage"
$env:DATALAKE_FILESYSTEM = "data"

Set-AzContext -SubscriptionName "Azure for Students" -TenantId ed5e260b-7dd8-421c-aec0-44b79108be72
$storage = Get-AzStorageAccount -Name $env:DATALAKE_NAME -ResourceGroupName $env:DATALAKE_RESOURCE_GROUP_NAME

$env:DATALAKE_SASTOKEN = (New-AzStorageContainerSASToken -Context $storage.Context `
                            -Container $env:DATALAKE_FILESYSTEM `
                            -StartTime (Get-Date) `
                            -ExpiryTime (Get-Date).AddMinutes((20)) `
                            -Permission w)

./scripts/publish-results-to-datalake.ps1