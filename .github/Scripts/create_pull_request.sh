#!/bin/bash

# 启用不区分大小写的匹配
shopt -s nocasematch

# 处理 PR 模板，定义替换规则
declare -A replacements=(
    ["\$PRTitle"]="$PRTitle"
    ["\$HeadOwner"]="$HeadOwner"
    ["\$GITHUB_SHA"]="$GITHUB_SHA"
)

# 执行替换
for pattern in "${!replacements[@]}"; do
    sed -i "s|${pattern}|${replacements[$pattern]}|g" "$TEMPLATE_FILE"
done

# 列出满足指定条件的 PR
PR_URL=$(gh pr list \
  --repo "$BaseOwner/nvda" \
  --state open \
  --author "@me" \
  --head "$BRANCH_NAME" \
  --base beta \
  --json url \
  --jq '.[0].url' 2>/dev/null || echo "")

# 检查是否存在满足条件的 PR，若已存在 PR，则输出该 PR 的 URL，否则创建新 PR
if [ -n "$PR_URL" ]; then
  STEP_SUMMARY="Existing pull request found: $PR_URL"
else
  echo "No existing pull request found. Creating new pull request..."
  PR_URL=$(gh pr create \
    --repo "$BaseOwner/nvda" \
    --title "$PRTitle" \
    --head "$HeadOwner:$BRANCH_NAME" \
    --base beta \
    --body-file "$TEMPLATE_FILE" \
    --draft)
  STEP_SUMMARY="Created draft pull request: $PR_URL"
fi

# 输出结果
echo "$STEP_SUMMARY"
echo "$STEP_SUMMARY" >> "$GITHUB_STEP_SUMMARY"
