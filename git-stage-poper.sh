#!/bin/bash

green='\033[0;32m'
yello='\033[0;33m'
red='\033[0;91m'
reset='\033[0m'

# fetch branchs
git fetch --all

user=$(git config user.name)
branches=$(git branch --list --all)

if [ $# -gt 0 ]; then
  target=$1
  echo -e "${green}use branch:${reset} $target"
else
  target=""
  max_timestamp=0

  while IFS= read -r branch; do
    timestamp=$(echo "$branch" | grep -oE "__tmp_${user}_[0-9]+" | sed "s/__tmp_${user}_//")
    if [ -n "$timestamp" ] && ((timestamp > max_timestamp)); then
      max_timestamp=$timestamp
      target=$branch
    fi
  done <<< "$branches"
  echo -e "${yello}[warn] use default branch:${reset}$target"
fi

current_commit=$(git rev-parse HEAD)
target_parent_commit=$(git rev-parse ${target}^)

# check if 'id(HEAD^) == id(target_parent)'
if [ "$current_commit" != "$target_parent_commit" ]; then
  echo -e "${red}HEAD is not target commit parent, please pull latest commit or switch to right branch${reset}"
  exit 1
fi

# check if workspace clean
if [ -n "$(git status --porcelain)" ]; then
  echo -e "${red}unclean branch, please commit or discard${reset}"
  exit 1
fi

# cherry-pick
if [ -n "$target" ]; then
  echo -e "${green}cherry-pick${reset} $target"
  git cherry-pick -n $target
  echo -e "${green}use this to delete remote tmp branch:${reset} git push origin --delete $(echo $target | sed 's|.*/||')"
else
  echo -e "${yello}no branch found!${reset}"
fi
