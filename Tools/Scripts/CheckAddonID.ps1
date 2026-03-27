# CheckAddonID.ps1
# Usage: powershell -File CheckAddonID.ps1 <ProjectListFilePath>

param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectListFile
)

# Check if Action environment variable is valid
if ($env:Action -ne "DownloadFiles" -and $env:Action -ne "UploadFiles") {
    exit 0
}

# Get values from environment variables
$configFilename = $env:ConfigFilename

# Define script block to check config file content
$checkConfigContent = {
    param($searchPattern)
    return (Test-Path $configFilename) -and ((Get-Content $configFilename -Raw) -match $searchPattern)
}

# Read and filter the file
Write-Host "Checking add-on ID validity..."
$found = $false
$firstIteration = $true

foreach ($line in (Get-Content $ProjectListFile | Where-Object { $_ -notmatch '^\s*#' })) {
    if ($line -match '^([^=]+)=(.+)$') {
        $projectId = $Matches[1].Trim()
        $searchPattern = "\b" + [regex]::Escape($ExecutionContext.InvokeCommand.ExpandString($Matches[2].Trim())) + "\.(po|xliff|md)\b"

        # Check if config file already contains the target pattern (only on first iteration)
        if ($firstIteration -and (& $checkConfigContent $searchPattern)) {
            $found = $true
            break
        }
        $firstIteration = $false

        # Execute command to write configuration
        $cmdLine = '%l10nUtil% writeConfig %Config% --id='+$projectId+' >nul'
        & cmd /c $cmdLine

        # Check config file after writing
        if (& $checkConfigContent $searchPattern) {
            $found = $true
            break
        }
    }
}

if (-not $found) {
    Write-Host "Error: Invalid add-on ID"
    exit 1
}

exit
