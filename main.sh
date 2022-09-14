#!/bin/bash

# the directory that stores the repos
repos="repositories/"
currentDir=$(pwd)
authorFile="authors.txt"
declare authors=()

# Text colouring
RED='\033[0;31m'
GREEN='\033[0;32m'
WHITE='\033[0;36m'
NC='\033[0m' # No Color

main () {
    if test -f "$authorFile"; then
        echo -e "${WHITE}$authorFile${NC} exists."
        checkAuthorFile
    else
        echo -e "${WHITE}$authorFile${NC} doesn't exist, ${GREEN}will create a new${NC} one based on the repositories in ${WHITE}$repos${NC}."
        findAllAuthors
    fi
}

findAllAuthors() {
    for repo in $repos*;
    do
        if [ -d "$repo" ]; then
            findAuthors $repo
        fi
    done

    # remove dups again
    authors=$(echo $authors | sort -u)
    
    for commiter in "${authors[@]}";
    do
        # authordata^
        # while replacing % with ' ' again
        echo $commiter","| sed 's/%/ /g' >> $authorFile
    done

    echo -e "\n${WHITE}$authorFile${NC} created\nIn order to continue, copy the updated author data after the ${WHITE}^${NC}\n"
    echo -e "${RED}Example 1${NC} changing author data\n${WHITE}pickle,pickle,pickle@gmail.com,pickle@gmail.com,${GREEN}yoda,yoda,yoda@gmail.com,yoda@gmail.com\n"
    echo -e "${RED}Example 2${NC} data remains the same\n${WHITE}pickle,pickle,pickle@gmail.com,pickle@gmail.com,${NC}\n"
    echo -e "${NC}Run the script again once completed"
}

findAuthors () {
    # $1 is the directory of the repo
    # This function will find all current authors in the repos provided as a list

    cd $1
    # get all author and commiter data, then replace any spaces with '%'
    # bc bash CANNOT handle spaces
    # then remove duplicates

    # https://devhints.io/git-log-format - for git log formats and variables
    local commiters=($(git log --pretty="format:%aN,%cN,%aE,%cE" | sed 's/ /%/g' | sort -u))
    cd $currentDir

    # merge two arrays together, global one with local one
    authors=("${authors[@]}" "${commiters[@]}")
}

checkAuthorFile () {
    while read line; do
        # if line does not end with ,
        if [ "${line: -1}" != "," ]; then
            checkAuthorLine "${line}"
            rewriteGit "${line}"
        fi
    done < "${authorFile}"
}

checkAuthorLine () {
    # takes line of author file as input
    # line is expected to be in modified form - example
    # pickle,pickle,pickle@gmail.com,pickle@gmail.com^yoda,yoda,yoda@gmail.com,yoda@gmail.com
    # sed is to remove space
    local numComma=$(grep -o "," <<<"$1" | wc -l | sed 's/ //g')

    #echo $numComma $numArrow $1
    if [ "$numComma" != "7" ]; then
        echo -e "${RED}Error, line is incorrectly formatted\n${WHITE}$1${NC}"
        exit
    fi
    
}

rewriteGit () {
    # Takes in one string of author data (validated)
    # https://www.git-tower.com/learn/git/faq/change-author-name-email/
    # This is very inefficient but it means I only have to deal with one
    # author to correct at a time - and plus, who is running this everyday?

    # iterate through each repo
    for repo in $repos*;
    do
        if [ -d "$repo" ]; then
            cd $repo

            # magic
            echo $1
             
            cd $currentDir
        fi
    done
}

gitFilter () {
    # Takes in one string of author data (validated)


    git filter-branch --env-filter '
    WRONG_EMAIL='wrong@example.com'
    NEW_NAME="New Name Value"
    NEW_EMAIL="correct@example.com"

    if [ "$GIT_COMMITTER_EMAIL" = "$WRONG_EMAIL" ]
    then
        export GIT_COMMITTER_NAME="$NEW_NAME"
        export GIT_COMMITTER_EMAIL="$NEW_EMAIL"
    fi
    if [ "$GIT_AUTHOR_EMAIL" = "$WRONG_EMAIL" ]
    then
        export GIT_AUTHOR_NAME="$NEW_NAME"
        export GIT_AUTHOR_EMAIL="$NEW_EMAIL"
    fi
    ' --tag-name-filter cat -- --branches --tags
}

main