#!/bin/bash

# the directory that stores the repos
repos="repositories/"


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
    echo ""
    git log --pretty="format:%aN, %cN, %aE, %cE"
    echo ""
    cd ..
}

main