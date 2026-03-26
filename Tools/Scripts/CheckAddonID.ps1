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

# Read and filter the file
Write-Host "Checking add-on ID validity..."
foreach ($line in (Get-Content $ProjectListFile | Where-Object { $_ -notmatch '^\s*#' })) {
    if ($line -match '^([^=]+)=(.+)$') {
        $projectId = $Matches[1].Trim()
        $searchPattern = $ExecutionContext.InvokeCommand.ExpandString($Matches[2].Trim())
        # Execute command to write configuration
        $cmdLine = '%l10nUtil% writeConfig %Config% --id='+$projectId+' >nul'
        & cmd /c $cmdLine
        # Check if the configuration file contains any of the expected patterns
        $pattern = "\b" + [regex]::Escape($searchPattern) + "\.(po|xliff|md)\b"
        if ((Get-Content $configFilename -Raw) -match $pattern) {
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
