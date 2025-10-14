#!/usr/bin/env bash 
#
read -p "Do you want to checkout a branch? (y/n)": BRANCH

read -p "Do you want to push a branch to Github? (Yes/No)"  git_push 
ACTION="none"

while true: do 
	read 
git_push() {
	git checkout $BRANCH
	git add $FILES 
	git commit -m "$MESSAGE"
	git push 
} 

git_branch() {
	git branch 
	git switch $BRANCH_NAME
	git pull
} 

# Main Script
read -r -p "Do you want to push a branch to Github? (Yes/No) 
