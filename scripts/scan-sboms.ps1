$here = Split-Path -Parent $PSCommandPath
$here = Split-Path -Parent $here

$sourceDir = "$here/raw"  
$targetDir = "$here/raw_flatterned/"  

# Remove-Item raw_flatterned\* -Recurse -Force

$jsonFiles = Get-ChildItem -Path $sourceDir -Filter *.json -Recurse

# New-Item -Path "$here/" -Name "raw_flatterned" -ItemType "directory"

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

bomber scan $here/raw_flatterned/ --output=json > results.json

Remove-Item $here/raw_flatterned\* -Recurse -Force