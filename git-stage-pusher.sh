#!/bin/bash

# ANSI color codes
green='\033[0;32m'
reset='\033[0m'

# get current branch name
current_branch=$(git rev-parse --abbrev-ref HEAD)
echo -e "${green}current branch:${reset} ${current_branch}"

# create temporary branch
new_branch="__tmp$(date +"%Y%m%d%H%M%S")"
git checkout -b "$new_branch"
echo -e "${green}create tmp branch:${reset} ${new_branch}"

# commit message
git commit -m "stash: $(date +"%Y%m%d%H%M%S")"
commit_id=$(git rev-parse ${new_branch})
echo -e "${green}commit:${reset} ${commit_id}"

# push tmp branch
echo -e "${green}push${reset}"
git push origin "$new_branch"

# switch back and restore commited info stash
git checkout "$current_branch"
git cherry-pick -n $commit_id
echo -e "${green}reset${reset}"

# delete local tmp branch
if [ -n "$(git diff)" ]; then
    exit 1
else
    echo -e "${green}delete local tmp branch${reset}"
    git branch -D ${new_branch}
fi

