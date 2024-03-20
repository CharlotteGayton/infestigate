Import-Module 'Az.Storage'

if(!($env:DATALAKE_NAME)){
    Throw "DATALAKE_NAME environment variable is not set or is empty. Please set it before continuing."
}
if(!($env:DATALAKE_SASTOKEN)){
    Throw "DATALAKE_SASTOKEN environment variable is not set or is empty. Please set it before continuing."
}
$newContext = New-AzStorageContext -StorageAccountName $env:DATALAKE_NAME -SasToken $env:DATALAKE_SASTOKEN
$filesystemName = "data"
$fileName = "analysing_vulnerability_data/results"

$destPath = "results/"

New-AzDataLakeGen2Item -Context $newContext -FileSystem $filesystemName -Path $destPath -Source $fileName  -Force | Out-Null