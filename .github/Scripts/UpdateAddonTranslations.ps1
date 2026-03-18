$ErrorActionPreference = 'Stop'
$AddonID = $env:AddonID
$L10nUtil = "$env:GITHUB_WORKSPACE/L10nUtilTools.bat"

if (-not $AddonID) {
    $dirs = Get-ChildItem -Path "$env:GITHUB_WORKSPACE\Translation\Addons" -Directory | Select-Object -ExpandProperty Name
    $AddonID = $dirs -join " "
}

$addonIds = $AddonID -split ' '
foreach ($addonId in $addonIds) {    
    if ([string]::IsNullOrWhiteSpace($addonId)) {
        continue
    }
    Write-Output "Processing add-on: $addonId"
    & cmd /c "$L10nUtil DAP $addonId"
    & cmd /c "$L10nUtil DAM $addonId"
    git add "Translation/Addons/$addonId"
}

exit
