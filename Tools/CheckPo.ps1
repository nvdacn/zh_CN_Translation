# 检查nvda.po文件的差异，如果只修改了日期行则还原
$filePath = "Translation/LC_MESSAGES/nvda.po"

# 获取文件的git diff输出（紧凑模式，不显示上下文）
$diffOutput = git diff --unified=0 $filePath

# 初始化标志位：假设只有日期修改
$onlyDateChanges = $true
$datePattern1 = '^[-+]"POT-Creation-Date:'
$datePattern2 = '^[-+]"PO-Revision-Date:'

# 逐行分析diff输出
foreach ($line in $diffOutput -split "`n") {
    # 检查实际的内容修改行（以+/-开头）
    if (($line.StartsWith("+") -or $line.StartsWith("-")) -and (-not $line.StartsWith("+++")) -and (-not $line.StartsWith("---"))) {
        # 如果发现非日期行的修改
        if (-not ($line -match $datePattern1) -and -not ($line -match $datePattern2)) {
            $onlyDateChanges = $false
            break
        }
    }
}

# 根据检查结果执行操作
if ($onlyDateChanges) {
    Write-Host "Detected only date line modifications. Reverting file..."
    Git restore $filePath
} else {
    Write-Host "Substantial changes detected. Keeping modifications."
}
Exit
