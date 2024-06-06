#!/bin/bash

# https://www.baeldung.com/linux/bash-for-loop-parallel


function main {
    GITHUB_ROOT_FOLDER=$1

    if [[ -z $GITHUB_ROOT_FOLDER ]];
    then
        echo `date`" - Missing mandatory arguments: path to your GitHub root folder."
        echo `date`" - Usage: ./update_all_github_repos.sh [your-root-github-folder]"
        exit 1
    fi

    cd $GITHUB_ROOT_FOLDER
    for d in */ ; do
        update_repo $d &
    done

    wait

    echo "All git repositories have been updated!"
}

function update_repo {
    echo "$d"
    cd $d
    git remote prune origin
    git stash && git pull --rebase
    result=$?
    git stash pop
    if [[ $result -ne 0 ]];
        then
            echo ">>>>> GLUPS!! Error in $d"
        fi
    cd ..
}


main $1