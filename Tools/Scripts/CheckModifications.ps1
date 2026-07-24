# CheckModifications.ps1
# Usage: powershell -File CheckModifications.ps1 <File>

param(
    [Parameter(Mandatory=$true, HelpMessage="The path to the file to be checked")]
    [string]$file
)

# 初始化变量  
$shouldRevert = $true
$checkPatterns = $null
$fileExtension = [System.IO.Path]::GetExtension($file).ToLower()

# 根据文件类型设置要检查的字符串模式
switch ($fileExtension) {
    '.po' {
        $checkPatterns = @(
            '^[-+]"POT-Creation-Date:',
            '^[-+]"PO-Revision-Date:'
        )
    }
    '.xliff' {
        $checkPatterns = @(
            '^[-+]  <file id'
        )
    }
    default {
        Write-Host "Unsupported file type: $fileExtension. Exiting..."
        exit 0
    }
}

# 获取文件的 git diff 输出  
$diffOutput = git diff --unified=0 $file

# 检查是否有有效的 diff 输出  
if (-not $diffOutput) {
    Write-Host "No file modification was detected"
    exit 0
}

# 逐行分析 diff 输出  
foreach ($line in $diffOutput -split "`n") {
    if (($line.StartsWith("+") -or $line.StartsWith("-")) -and (-not $line.StartsWith("+++")) -and (-not $line.StartsWith("---"))) {
        $patternNotFound = $true
        foreach ($pattern in $checkPatterns) {
            if ($line -match $pattern) {
                $patternNotFound = $false
                break
            }
        }
        if ($patternNotFound) {
            $shouldRevert = $false
            break
        }
    }
}

# 根据检查结果执行操作  
if ($shouldRevert) {
    Write-Host "No meaningful modifications detected. Reverting the file..."
    Git restore $file
} else {
    Write-Host "Substantial changes detected. Keeping modifications."
}
Exit
