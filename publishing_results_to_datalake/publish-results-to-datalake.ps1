$requiredModules = @(
    @{Name="Az.Storage"; Version="5.3.0"}
)
$requiredModules | ForEach-Object {
    $name = $_.Name
    $version = $_.Version
    if ( !(Get-Module -ListAvailable $name | ? { $_.Version -eq ($version -split "-")[0] }) ) {
        $splat = @{
            Name=$name
            RequiredVersion=$version
            Scope="CurrentUser"
            Repository="PSGallery"
            Force=$true
            AllowPrerelease=$version.Contains("-")
        }
        Install-Module @splat
    }
    if (!(Get-Module $name)) {
        # Lookup the required version of the installed module to get the path to the module manifest
        Import-Module (Get-Module -ListAvailable $name | ? { $_.Version -eq ($version -split "-")[0] } | Select -ExpandProperty Path)
    }
}

# if(!($env:DATALAKE_NAME)){
#     Throw "DATALAKE_NAME environment variable is not set or is empty. Please set it before continuing."
# }
# if(!($env:DATALAKE_SASTOKEN)){
#     Throw "DATALAKE_SASTOKEN environment variable is not set or is empty. Please set it before continuing."
# }

$newContext = New-AzStorageContext -StorageAccountName $env:DATALAKE_NAME -SasToken $env:DATALAKE_SASTOKEN
$filesystemName = "data"
$fileName = "analysing_vulnerability_data/results/"

$destPath = "results/"

New-AzDataLakeGen2Item -Context $newContext -FileSystem $filesystemName -Path $destPath -Source $fileName  -Force | Out-Null
