# 弹窗函数
function Show-Popup {
    param([string]$Message, [string]$Title = "Auto Merge", [int]$Timeout = 10, [int]$IconType = 16)
    (New-Object -ComObject wscript.shell).Popup($Message, $Timeout, $Title, $IconType)
}

# 获取当前分支名
$currentBranch = git branch --show-current

# 检查当前分支是否为 Uploads
if ($currentBranch -eq "Uploads") {
    Show-Popup "Current branch is Uploads, merge operation is not allowed." "Error" 10 16
    exit 1
}

# 检查本地是否存在 Uploads 分支
$uploadsExists = git branch --list Uploads
if (-not $uploadsExists) {
    Show-Popup "Local branch Uploads does not exist." "Error" 10 16
    exit 1
}

# 尝试合并 Uploads 到当前分支
Write-Host "Merging Uploads branch into $currentBranch ..."
git merge Uploads --no-commit --no-ff 2>&1

# 检查是否有冲突
$conflictFiles = git diff --name-only --diff-filter=U

if (-not $conflictFiles) {
    # 无冲突，直接提交（使用默认合并提交消息）
    git commit --no-edit
    Write-Host "Merge successful, committed with default message."
    exit 0
}

# 有冲突，分离 .po 文件和其他冲突文件
$poConflicts = @()
$otherConflicts = @()

foreach ($file in $conflictFiles) {
    if ($file -like "*.po") {
        $poConflicts += $file
    } else {
        $otherConflicts += $file
    }
}

# 处理 .po 文件的冲突（支持多个 .po 文件）
if ($poConflicts.Count -gt 0) {
    Write-Host "Found $($poConflicts.Count) .po file(s) with conflicts, processing..."
    
    foreach ($poFile in $poConflicts) {
        $baseName = [System.IO.Path]::GetFileName($poFile)
        $tempCurrent = "current_$baseName"
        $tempUploads = "uploads_$baseName"

        Write-Host "Processing: $poFile"

        # 提取合并前的该文件（当前分支版本）
        git show HEAD:$poFile > $tempCurrent 2>$null

        # 从 Uploads 分支提取该文件
        git show Uploads:$poFile > $tempUploads 2>$null

        # 标记该文件为已解决冲突
        git add $poFile

        # 复制当前分支提取的文件替换冲突的文件
        if (Test-Path $tempCurrent) {
            Copy-Item $tempCurrent $poFile -Force
        }

        # 使用 msgmerge 将 Uploads 的文件合并到当前文件
        if ((Test-Path $tempUploads) -and (Test-Path $poFile)) {
            & msgmerge.exe --update $poFile $tempUploads 2>$null
        }

        # 查找以 #~ 开头的行，读取从该行到文件末尾的所有内容
        $obsoleteContent = ""
        if (Test-Path $poFile) {
            $lines = Get-Content $poFile
            $startIndex = -1
            for ($i = 0; $i -lt $lines.Count; $i++) {
                if ($lines[$i] -match "^#~") {
                    $startIndex = $i
                    break
                }
            }
            if ($startIndex -ne -1) {
                $obsoleteContent = $lines[$startIndex..($lines.Count-1)] -join "`r`n"
            }
        }

        # 复制从 Uploads 分支提取的文件替换当前文件
        if (Test-Path $tempUploads) {
            Copy-Item $tempUploads $poFile -Force
        }

        # 将此前读取的内容追加到当前文件末尾
        if ($obsoleteContent) {
            Add-Content $poFile "`r`n$obsoleteContent"
        }

        # 使用 msgmerge 将从当前分支提取的文件合并到当前文件
        if ((Test-Path $tempCurrent) -and (Test-Path $poFile)) {
            & msgmerge.exe --update $poFile $tempCurrent 2>$null
        }

        # 清理临时文件
        Remove-Item $tempCurrent -Force -ErrorAction SilentlyContinue
        Remove-Item $tempUploads -Force -ErrorAction SilentlyContinue
        
        # 将处理后的文件加入暂存区
        git add $poFile
        
        Write-Host "Completed: $poFile"
    }
    
    Write-Host "All $($poConflicts.Count) .po file(s) processed."
}

# 检查是否还有其他冲突文件
$remainingConflicts = git diff --name-only --diff-filter=U
if ($remainingConflicts) {
    Write-Host "Remaining unresolved conflict files:"
    $remainingConflicts | ForEach-Object { Write-Host "  $_" }
    Show-Popup "There are still unresolved conflict files (non-.po type). Please resolve them manually and commit.`nConflict file list is shown in the command line window." "Merge Conflict" 15 48
    exit 2
}

# 所有冲突已解决，提交合并（使用默认合并提交消息）
git commit --no-edit
Write-Host "All conflicts resolved, merge committed successfully with default message."
exit 0