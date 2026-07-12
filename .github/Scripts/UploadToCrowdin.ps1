param(
    [string]$TranslationType = "NVDA"
)

$ErrorActionPreference = 'Stop'
$GitBefore = $env:GITHUB_EVENT_BEFORE
$L10nUtil = "$env:GITHUB_WORKSPACE/L10nUtilTools.bat"
$IsBeforeValid = $false
if ($TranslationType -ieq "NVDA") {
    $ProcessedFileList = "Translation/LC_MESSAGES/*.po", "Translation/user_docs/*.xliff"
    $ProcessFunction = ${function:ProcessChangedNVDAFile}
} else {
    $ProcessedFileList = "Translation/Addons/*"
    $ProcessFunction = ${function:ProcessChangedAddonFile}
}

function ProcessChangedNVDAFile {
    param(
        [string]$File
    )
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($File)
    if ($baseName -ieq "nvda") {
        $FilePath = "Translation/LC_MESSAGES/$baseName.po"
    } else {
        $FilePath = "Translation/user_docs/$baseName.xliff"
    }
    if (Test-Path $FilePath) {
        Write-Host "Uploading $File to Crowdin..."
        & cmd /c "$L10nUtil UP_$baseName"
        Start-Sleep -Seconds 5
        Write-Host "Downloading updated $File from Crowdin..."
        & cmd /c "$L10nUtil DL_$baseName"
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
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($File)
    $fileExtension = [System.IO.Path]::GetExtension($File)
    if ($fileExtension -ieq ".po") {
        $actionType = "UAP"
    } else {
        $actionType = "UAX"
    }
    $FilePath = "Translation/Addons/$AddonID/$baseName$fileExtension"
    if (Test-Path $FilePath) {
        Write-Host "Uploading $File to Crowdin..."
        echo "has_changes=true" >> $env:GITHUB_OUTPUT
        & cmd /c "$L10nUtil $actionType $AddonID"
    } else {
        Write-Host "File $FilePath not found, skipping processing."
    }
}

git branch main remotes/origin/main

if ($GitBefore) {
    git rev-parse --verify -q "$GitBefore^{commit}" > $null 2>&1
    if ($LASTEXITCODE -eq 0) {
        $IsBeforeValid = $true
    }
}

if ($IsBeforeValid) {
    Write-Host "Comparing changes in range: $GitBefore"
    $diffRange = "$GitBefore..HEAD"
} else {
    Write-Host "Fallback: Fetching latest main branch"
    $MainHead = (git rev-parse "main")
    $diffRange = "$MainHead..HEAD"
}

foreach ($ProcessedFileName in $ProcessedFileList) {
    $changedFiles = git diff --name-only $diffRange -- $ProcessedFileName
    foreach ($file in $changedFiles) {
        Write-Host "$file has changed"
        & $ProcessFunction -File $file
    }
}
