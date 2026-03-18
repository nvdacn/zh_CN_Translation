$ErrorActionPreference = "Stop"
git config --global user.name "GitHub Actions"
git config --global user.email "actions@github.com"
&7z.exe e "$env:GITHUB_WORKSPACE\PotXliff\Temp\gettext.zip" "bin\msgmerge.exe" -aoa -o"$env:GITHUB_WORKSPACE\Tools" -bsp0 -bso0
cd "$env:GITHUB_WORKSPACE\Tools\NVDA"
$commit = (git rev-parse HEAD).Substring(0,8)
.\runcheckpot.bat --all-cores
cd "$env:GITHUB_WORKSPACE"
&"$env:GITHUB_WORKSPACE\Tools\msgmerge.exe" --update  --backup=none --previous "$env:GITHUB_WORKSPACE\Translation\LC_MESSAGES\nvda.po" "$env:GITHUB_WORKSPACE\Tools\NVDA\output\nvda.pot"
git add "Translation/LC_MESSAGES/nvda.po"
git diff --cached --quiet
if ($LASTEXITCODE -ne 0) {
    git commit -m "更新 NVDA 界面消息翻译字符串（alpha-$commit）"
    git pull --rebase
    git push origin $env:branch:$env:branch
} else {
    Write-Host "No changes to commit, skipping commit and push."
}

exit
