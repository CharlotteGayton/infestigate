Install-Module -Name bomber -Scope CurrentUser -Force

$sourceDir = 'raw'  
$targetDir = 'raw_flatterned/'  

$jsonFiles = Get-ChildItem -Path $sourceDir -Filter *.json -Recurse

foreach ($file in $jsonFiles) {
    Copy-Item -Path $file.FullName -Destination $targetDir
}

$subDirs = Get-ChildItem -Path $targetDir -Directory

foreach ($dir in $subDirs) {
    Remove-Item -Path $dir.FullName -Recurse -Force
}

$flatternedDirFiles = Get-ChildItem -Path $targetDir -Filter *.json

foreach ($file in $flatternedDirFiles){
    dotnet-covenant convert spdx $file.FullName -o $file.FullName
}

bomber scan ./raw_flatterned/ --output=json > results.json

Remove-Item raw_flatterned\* -Recurse -Force
