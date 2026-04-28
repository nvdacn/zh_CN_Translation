# encoding: utf-8-bom

# 设置编码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 > $null

# 设置工作目录
Set-Location "$PSScriptRoot\..\.."
Write-Host "当前工作目录: $(Get-Location)"

# 弹窗函数
function Show-Popup {
    param([string]$Message, [string]$Title = "自动合并", [int]$Timeout = 10, [int]$IconType = 16)
    (New-Object -ComObject wscript.shell).Popup($Message, $Timeout, $Title, $IconType)
}

# 获取当前分支名
$currentBranch = git branch --show-current

# 检查当前分支能否执行合并操作
if ($currentBranch -eq "Uploads" -or $currentBranch -eq "main") {
    Show-Popup "当前分支不允许执行合并操作。" "错误" 10 16
    exit 1
}

# 检查本地是否存在 Uploads 分支
$uploadsExists = git branch --list Uploads
if (-not $uploadsExists) {
    Show-Popup "本地不存在 Uploads 分支，请创建该分支后重试。" "错误" 10 16
    exit 1
}

# 拉取上游分支
Write-Host "正在拉取上游分支..."
git pull --rebase --ff-only --quiet

# 尝试合并 Uploads 到当前分支
Write-Host "正在将 Uploads 分支合并到 $currentBranch..."
git merge Uploads --no-commit --no-ff 2>&1

# 检查是否有冲突
$conflictFiles = git diff --name-only --diff-filter=U
if (-not $conflictFiles) {
    # 无冲突，直接提交
    git commit --no-edit
    Write-Host "合并成功。"
    exit 0
}

# 有合并冲突，定义必须变量
$poConflicts = @()
$msgmerge = "C:\Program Files\Poedit\GettextTools\bin\msgmerge.exe"
$tempFolder = "$PSScriptRoot/../../PotXliff/Temp"
$sevenZipPath = "Tools\7Zip\7z.exe"

foreach ($file in $conflictFiles) {
    if ($file -like "*.po") {
        $poConflicts += $file
    }
}

# 从存储库指定分支提取 po 文件的函数
function ExtractPOFileFromRepo {
    param([string]$BranchName, [string]$PoFilePath, [string]$OutputPath)
    $zipFile = [System.IO.Path]::GetFileName($OutputPath) + ".zip"
    $extractedFile = "PotXliff\$fileName"
    Write-Host "  从 [$BranchName] 分支提取 $PoFilePath ..."
    git archive --output "$tempFolder/$zipFile" $BranchName $PoFilePath
    & $sevenZipPath -sccUTF-8 -bsp0 -bso0 e "$tempFolder\$zipFile" $PoFilePath -aoa -o"PotXliff"
    Move-Item -Path $extractedFile -Destination $OutputPath -Force
}

# 处理 .po 文件的冲突
if ($poConflicts.Count -gt 0) {
    Write-Host "发现 $($poConflicts.Count) 个 .po 文件存在冲突，正在处理..."

    foreach ($poFile in $poConflicts) {
        $fileName = [System.IO.Path]::GetFileName($poFile)
        $index = [array]::IndexOf($poConflicts, $poFile) + 1
        $baseName = "$($fileName.Replace('.po', ''))_$index.po"
        $tempCurrent = "PotXliff\current_$baseName"
        $tempContent = "PotXliff\Content_$baseName"
        $tempUploads = "PotXliff\uploads_$baseName"

        Write-Host "正在处理: $poFile"

        # 提取 po 文件
        if (Test-Path $tempFolder) {
            Remove-Item -Path $tempFolder -Recurse -Force
        }
        New-Item -Path $tempFolder -ItemType Directory -Force | Out-Null
        ExtractPOFileFromRepo -BranchName $currentBranch -PoFilePath $poFile -OutputPath $tempCurrent
        ExtractPOFileFromRepo -BranchName "Uploads" -PoFilePath $poFile -OutputPath $tempUploads

        # 使用 msgmerge 将 Uploads 的文件合并到当前文件
        & $msgmerge --previous --quiet --output-file=$tempContent $tempCurrent $tempUploads

        # 查找以 #~ 开头的行，读取从该行到文件末尾的所有内容
        $obsoleteContent = ""
        $lines = Get-Content $tempContent
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

        # 将此前读取的内容追加到当前文件末尾
        if ($obsoleteContent) {
            Add-Content -Path $tempUploads -Value "$obsoleteContent" -Encoding utf8
        }

        # 使用 msgmerge 将从当前分支提取的文件合并到当前文件
        & $msgmerge --previous --quiet --output-file=$poFile $tempUploads $tempCurrent

        # 将处理后的文件加入暂存区
        git add $poFile
        
        Write-Host "已完成: $poFile"
    }
    
    Write-Host "所有 $($poConflicts.Count) 个 .po 文件已处理完成。"
}

# 检查是否还有其他冲突文件
$remainingConflicts = git diff --name-only --diff-filter=U
if ($remainingConflicts) {
    Write-Host "剩余未解决的冲突文件："
    $remainingConflicts | ForEach-Object { Write-Host "  $_" }
    Show-Popup "仍存在未解决的冲突文件，请手动解决合并冲突后提交。" "合并冲突" 15 48
    exit 2
}

# 所有冲突已解决，提交合并
git commit --no-edit
Write-Host "所有冲突已解决，合并成功提交。"
exit 0
