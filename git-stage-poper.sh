#!/bin/bash

green='\033[0;32m'
yello='\033[0;33m'
reset='\033[0m'

# fetch branchs
git fetch --all

branches=$(git branch --list --all)

if [ $# -gt 0 ]; then
  target=$1
  echo -e "${green}use branch:${reset} $target"
else
  target=""
  max_timestamp=0

  while IFS= read -r branch; do
    timestamp=$(echo "$branch" | grep -oE '__tmp[0-9]+' | sed 's/__tmp//')
    if [ -n "$timestamp" ] && ((timestamp > max_timestamp)); then
      max_timestamp=$timestamp
      target=$branch
    fi
  done <<< "$branches"
  echo -e "${yello}[warn] use default branch:${reset}$target"
fi

# cherry-pick
if [ -n "$target" ]; then
  echo -e "${green}cherry-pick${reset} $target"
  git cherry-pick -n $target
else
  echo -e "${yello}no branch found!${reset}"
fi
