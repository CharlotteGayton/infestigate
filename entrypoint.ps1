#!/usr/bin/pwsh
[CmdletBinding()]
param (
    [Parameter()]
    [string] $SbomPath = ($env:INFESTIGATE_INPUT_PATH ?? "/input"),

    [Parameter()]
    [string] $OutputPath = ($env:INFESTIGATE_RESULTS_PATH ?? "/output"),

    [Parameter()]
    [switch] $ConvertToSpdx
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$here = Split-Path -Parent $PSCommandPath

Write-Host -f Green "***"
Write-Host -f Green "*** Starting Infestigate analysis"
Write-Host -f Green "***"

Write-Host "Configuration:"
Write-Host " SbomPath: $SbomPath"
Write-Host " OutputPath: $OutputPath"
Write-Host " ConvertToSpdx?: $ConvertToSpdx`n"

if (Test-Path -PathType Container $SbomPath) {
    $sbomsToProcess = Get-ChildItem $SbomPath -Filter *.json
}
else {
    $sbomsToProcess = @($SbomPath)
}

foreach ($sbom in $sbomsToProcess) {
    $sbomFilename = Split-Path $sbom -Leaf
    Write-Host -f Green "Processing SBOM: $sbomFilename"

    if ($ConvertToSpdx) {
        Write-Host "--> Converting $sbom to SPDX format"
        $sbomToAnalyse = Join-Path ([IO.Path]::GetTempPath()) $sbomFilename
        & ~/.dotnet/tools/dotnet-covenant convert spdx $sbom -o $sbomToAnalyse
    }
    else {
        $sbomToAnalyse = $sbom
    }

    if (-not $OutputPath) {
        $OutputPath = Join-Path "/output" "$sbomFilename-analysis.json"
    }

    Write-Host "--> Analysing SBOM: $sbomToAnalyse"
    $trivyOutput = Join-Path $OutputPath "$sbomFilename-analysis.json"
    & trivy sbom $sbomToAnalyse --format json --output $trivyOutput
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Trivy failed to analyse $sbomToAnalyse - check previous errors. [StatusCode=$LASTEXITCODE]"
    }

    $env:INFESTIGATE_INPUT_PATH = $trivyOutput
    $env:INFESTIGATE_SCANNED_SBOM_PATH = $OutputPath
    $env:INFESTIGATE_RESULTS_PATH = $OutputPath
    Write-Host -f Green "`nAnalysing SBOM Vulnerabilities"
    Write-Host -NoNewLine "--> Analysing trivy output: $trivyOutput"
    & python3 $here/analysing_data.py
}
