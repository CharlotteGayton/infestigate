#!/usr/bin/env pwsh

$here = Split-Path -Parent $PSCommandPath
$here = Split-Path -Parent $here

$sourceDir = "$here/raw"  
$targetDir = "$here/raw_flatterned"  

if (-not (Test-Path $targetDir -PathType Container)) {
    New-Item -ItemType Directory -Force -Path $targetDir
}

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

bomber scan $here/raw_flatterned/ --output=json > $here/scripts/results.json

Remove-Item $here/raw_flatterned/* -Recurse -Force