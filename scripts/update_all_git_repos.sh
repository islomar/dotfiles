#!/bin/bash


function main {
    GIT_REPOS_ROOT_FOLDER=$1

    if [[ -z $GIT_REPOS_ROOT_FOLDER ]];
    then
        echo `date`" - Missing mandatory arguments: path to your Git repositoris root folder."
        echo `date`" - Usage: ./update_all_git_repos.sh [your-root-git-repos-folder]"
        exit 1
    fi

    cd $GIT_REPOS_ROOT_FOLDER
    for repo_folder in */ ; do
        update_repo $repo_folder &
    done

    wait

    echo -e "\nAll git repositories have been updated!"
}

function update_repo {
    echo "Updating $repo_folder"
    cd $repo_folder
    git remote prune origin > /dev/null 2>&1
    git stash > /dev/null 2>&1 && git pull --rebase
    result=$?
    git stash pop > /dev/null 2>&1
    if [[ $result -ne 0 ]];
        then
            echo ">>>>> GLUPS!! Error in $repo_folder"
        fi
    cd ..
}


main $1