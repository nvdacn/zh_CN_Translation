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
foreach ($line in (Get-Content $ProjectListFile | Where-Object { $_ -notmatch '^\s*#' })) {
    if ($line -match '^([^=]+)=(.+)$') {
        $projectId = $Matches[1].Trim()
        $searchPattern = $ExecutionContext.InvokeCommand.ExpandString($Matches[2].Trim())+'.'
        # Execute command to write configuration
        $cmdLine = '%l10nUtil% writeConfig %Config% --id='+$projectId
        & cmd /c $cmdLine
        # Check if the configuration file contains the expected pattern
        if ((Get-Content $configFilename -Raw) -match [regex]::Escape($searchPattern)) {
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
