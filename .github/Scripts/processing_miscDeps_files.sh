#!/bin/bash

cd "$ZHCNPath"
echo "Current directory: $(pwd)"
echo "Configuring git..."
git remote add NVDACN https://github.com/$HeadOwner/nvda.git
git config --global user.name "GitHub Actions"
git config --global user.email "actions@github.com"
git switch -c PullRequestToNVDA origin/beta
echo "Current branch: $(git branch --show-current)"
for f in \
  characterDescriptions.dic \
  gestures.ini \
  symbols.dic
do
  echo "Processing file: $f"
  if [ -f "$ZHCNPath/$f" ]; then
    rm -f "$ZHCNPath/$f"
  fi
  echo "Copying from: $miscDepsPath/$f"
  cp -f "$miscDepsPath/$f" "$ZHCNPath/"
  git add "$ZHCNPath/$f"
done
if [ -z "$(git status --porcelain)" ]; then
  echo "No changes to commit."
  echo "changes_exist=false" >> $GITHUB_OUTPUT
else
  git commit -m "Update translations"
  git push --force NVDACN PullRequestToNVDA:PullRequestToNVDA
  echo "changes_exist=true" >> $GITHUB_OUTPUT
fi
