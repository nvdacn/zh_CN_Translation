# 检查 nvda.po 文件的差异，如果只修改了 `POT-Creation-Date` 和 `PO-Revision-Date` 行则还原  
$filePath = "Translation/LC_MESSAGES/nvda.po"

# 获取文件的 git diff 输出  
$diffOutput = git diff --unified=0 $filePath

# 初始化变量  
$onlyDateChanges = $true
$datePattern1 = '^[-+]"POT-Creation-Date:'
$datePattern2 = '^[-+]"PO-Revision-Date:'

# 逐行分析 diff 输出  
foreach ($line in $diffOutput -split "`n") {
    if (($line.StartsWith("+") -or $line.StartsWith("-")) -and (-not $line.StartsWith("+++")) -and (-not $line.StartsWith("---"))) {
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
