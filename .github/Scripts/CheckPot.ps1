$ErrorActionPreference = "Stop"
git config --global user.name "GitHub Actions"
git config --global user.email "actions@github.com"
&7z.exe e "${{ github.workspace }}\PotXliff\Temp\gettext.zip" "bin\msgmerge.exe" -aoa -o"${{ github.workspace }}\Tools"
cd "${{ github.workspace }}/Tools/NVDA"
$commit = (git rev-parse HEAD).Substring(0,8)
&runcheckpot.bat --all-cores
cd "${{ github.workspace }}"
&"${{ github.workspace }}\Tools\msgmerge.exe" --update  --backup=none --previous "${{ github.workspace }}\Translation\LC_MESSAGES\nvda.po" "${{ github.workspace }}\Tools\NVDA\output\nvda.pot"
git add "Translation/LC_MESSAGES/nvda.po"
git diff --cached --quiet
if ($LASTEXITCODE -ne 0) {
    git commit -m "更新 NVDA 界面消息翻译字符串（alpha-$commit）"
    git pull --rebase
    git push origin ${{ needs.Determine-Branch.outputs.branch }}:${{ needs.Determine-Branch.outputs.branch }}
} else {
    Write-Host "No changes to commit, skipping commit and push."
}
