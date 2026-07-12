param(
    [string]$TranslationType = "NVDA"
)

$ErrorActionPreference = 'Stop'
$GitBefore = $env:GITHUB_EVENT_BEFORE
$L10nUtil = "$PSScriptRoot/../../L10nUtilTools.bat"
$IsBeforeValid = $false

function ProcessChangedNVDAFile {
    param(
        [string]$File
    )
    $BaseName = [System.IO.Path]::GetFileNameWithoutExtension($File)
    if ($BaseName -ieq "nvda") {
        $FilePath = "Translation/LC_MESSAGES/$BaseName.po"
    } else {
        $FilePath = "Translation/user_docs/$BaseName.xliff"
    }
    if (Test-Path $FilePath) {
        Write-Host "Uploading $File to Crowdin..."
        & $L10nUtil "UP_$BaseName"
        Start-Sleep -Seconds 5
        Write-Host "Downloading updated $File from Crowdin..."
        & $L10nUtil "DL_$BaseName"
        git add "$File"
        Write-Host "Staged changes for $File"
    } else {
        Write-Host "File $FilePath not found, skipping processing."
    }
}

function ProcessChangedAddonFile {
    param(
        [string]$File
    )
    $AddonID = [System.IO.Path]::GetFileName([System.IO.Path]::GetDirectoryName($File))
    $BaseName = [System.IO.Path]::GetFileNameWithoutExtension($File)
    $FileExtension = [System.IO.Path]::GetExtension($File)
    if ($FileExtension -ieq ".po") {
        $ActionType = "UAP"
    } else {
        $ActionType = "UAX"
    }
    $FilePath = "Translation/Addons/$AddonID/$BaseName$FileExtension"
    if (Test-Path $FilePath) {
        Write-Host "Uploading $File to Crowdin..."
        echo "has_changes=true" >> $env:GITHUB_OUTPUT
        & $L10nUtil $ActionType $AddonID
    } else {
        Write-Host "File $FilePath not found, skipping processing."
    }
}

git branch -f main remotes/origin/main

if ($GitBefore) {
    git rev-parse --verify -q "$GitBefore^{commit}" > $null 2>&1
    if ($LASTEXITCODE -eq 0) {
        $IsBeforeValid = $true
    }
}

if ($IsBeforeValid) {
    Write-Host "Comparing changes in range: $GitBefore"
    $DiffRange = "$GitBefore..HEAD"
} else {
    Write-Host "Fallback: Fetching latest main branch"
    $MainHead = (git rev-parse "main")
    $DiffRange = "$MainHead..HEAD"
}

if ($TranslationType -ieq "NVDA") {
    $ProcessedFileList = "Translation/LC_MESSAGES/*.po", "Translation/user_docs/*.xliff"
    $ProcessFunction = "ProcessChangedNVDAFile"
} else {
    $ProcessedFileList = "Translation/Addons/*"
    $ProcessFunction = "ProcessChangedAddonFile"
}

foreach ($ProcessedFileName in $ProcessedFileList) {
    $ChangedFiles = git diff --name-only $DiffRange -- $ProcessedFileName
    foreach ($File in $ChangedFiles) {
        Write-Host "$File has changed"
        & $ProcessFunction -File $File
    }
}

exit
