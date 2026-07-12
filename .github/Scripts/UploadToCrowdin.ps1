$ErrorActionPreference = 'Stop'
$GitBefore = $env:GITHUB_EVENT_BEFORE
$L10nUtil = "$env:GITHUB_WORKSPACE/L10nUtilTools.bat"
$IsBeforeValid = $false
$ProcessedFileList = "Translation/LC_MESSAGES/*.po", "Translation/user_docs/*.xliff"

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
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file)
        if ($baseName -ieq "nvda") {
            $FilePath = "Translation/LC_MESSAGES/$baseName.po"
        } else {
            $FilePath = "Translation/user_docs/$baseName.xliff"
        }
        if (Test-Path $FilePath) {
            Write-Host "Uploading $file to Crowdin..."
            & cmd /c "$L10nUtil UP_$baseName"
            Start-Sleep -Seconds 5
            Write-Host "Downloading updated $file from Crowdin..."
            & cmd /c "$L10nUtil DL_$baseName"
            git add "$file"
            Write-Host "Staged changes for $file"
        } else {
            Write-Host "File $FilePath not found, skipping processing."
        }
    }
}
