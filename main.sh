#!/bin/bash

# the directory that stores the repos
repos="repositories/"
currentDir=$(pwd)


# https://www.git-tower.com/learn/git/faq/change-author-name-email/
# https://devhints.io/git-log-format - for git log formats and variables

main () {
    for repo in $repos*;
    do
        if [ -d "$repo" ]; then
            findAuthors $repo
        fi
    done
}

findAuthors () {
    # $1 is the directory of the repo
    # This function will find all current authors in the repos provided as a list

    cd $1
    # get all author and commiter data, then replace any spaces with '%'
    # bc bash CANNOT handle spaces
    commiters=($(git log --pretty="format:%aN,%cN,%aE,%cE" | sed 's/ /%/g'))
    cd $currentDir
    for commiter in "${commiters[@]}";
    do
        echo $commiter
    done

}

main