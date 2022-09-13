#!/bin/bash
# the directory that stores the repos
repos="repositories/"


# https://www.git-tower.com/learn/git/faq/change-author-name-email/
# https://devhints.io/git-log-format - for git log formats and variables

main () {
    for repo in $repos*;
    do
        if [ -d "$repo" ]; then
            echo "$repo"
        fi
    done
}

findAuthors () {
    # This function will find all current authors in the repos provided as a list
    echo null
}

main