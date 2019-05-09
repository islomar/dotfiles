#!/bin/bash

GITHUB_ROOT_FOLDER=$1

if [[ -z $GITHUB_ROOT_FOLDER ]];
then
    echo `date`" - Missing mandatory arguments: path to your GitHub root folder."
    echo `date`" - Usage: ./update_all_github_repos.sh [your-root-github-folder]"
    exit 1
fi

cd $GITHUB_ROOT_FOLDER
for d in */ ; do
    echo "$d"
    cd $d
    git remote prune origin
    git pull --rebase
    cd ..
done