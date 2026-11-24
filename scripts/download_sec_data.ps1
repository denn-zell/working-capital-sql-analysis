# Downloads the SEC Financial Statement Data Sets for a range of quarters
# and extracts each one into data/raw/<year>q<quarter>/.
#
# The SEC asks automated tools to identify themselves with a name and an
# email address. Pass yours via -UserAgent, it is not stored anywhere.
#
# Usage:
#   .\scripts\download_sec_data.ps1 -UserAgent "Your Name your.email@example.com"

param(
    [Parameter(Mandatory = $true)]
    [string]$UserAgent,
    [int]$StartYear = 2015,
    [int]$StartQuarter = 1,
    [int]$EndYear = 2026,
    [int]$EndQuarter = 3
)

$ErrorActionPreference = "Stop"
# The progress bar makes Expand-Archive much slower in Windows PowerShell
$ProgressPreference = "SilentlyContinue"

$baseUrl = "https://www.sec.gov/files/dera/data/financial-statement-data-sets"
$rawDir = Join-Path $PSScriptRoot "..\data\raw"

for ($year = $StartYear; $year -le $EndYear; $year++) {
    for ($quarter = 1; $quarter -le 4; $quarter++) {
        if ($year -eq $StartYear -and $quarter -lt $StartQuarter) { continue }
        if ($year -eq $EndYear -and $quarter -gt $EndQuarter) { break }

        $name = "${year}q${quarter}"
        $targetDir = Join-Path $rawDir $name

        if (Test-Path (Join-Path $targetDir "num.txt")) {
            Write-Host "$name already exists, skipping"
            continue
        }

        Write-Host "Downloading $name ..."
        $zipPath = Join-Path $rawDir "$name.zip"
        # curl.exe ships with Windows 10/11 and sends the user agent unchanged
        curl.exe --fail --silent --show-error --location --retry 3 --user-agent $UserAgent --output $zipPath "$baseUrl/$name.zip"
        if ($LASTEXITCODE -ne 0) { throw "Download of $name failed" }
        # extract into a temporary folder first, so an interrupted run
        # never leaves a half-extracted quarter behind
        $partialDir = "$targetDir.partial"
        Expand-Archive -Path $zipPath -DestinationPath $partialDir -Force
        Rename-Item -Path $partialDir -NewName $name
        Remove-Item $zipPath

        # stay below the SEC limit of 10 requests per second
        Start-Sleep -Seconds 1
    }
}

Write-Host "Done."