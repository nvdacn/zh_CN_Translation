#!/bin/bash

# 启用不区分大小写的匹配
shopt -s nocasematch

# 确定分支名称
if [[ "$BaseOwner" == "$HeadOwner" ]]; then
    echo "BRANCH_NAME=PullRequestToNVDA" >> $GITHUB_ENV
else
    echo "BRANCH_NAME=$HeadOwner:PullRequestToNVDA" >> $GITHUB_ENV
fi

# 定义替换规则
declare -A replacements=(
    ["\$PRTitle"]="$PRTitle"
    ["\$HeadOwner"]="$HeadOwner"
    ["\$GITHUB_SHA"]="$GITHUB_SHA"
)

# 执行替换
for pattern in "${!replacements[@]}"; do
    sed -i "s|${pattern}|${replacements[$pattern]}|g" "$TEMPLATE_FILE"
done
