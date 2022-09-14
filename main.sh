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


# https://www.git-tower.com/learn/git/faq/change-author-name-email/
# https://devhints.io/git-log-format - for git log formats and variables

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
        echo $commiter"^"| sed 's/%/ /g' >> $authorFile
    done

    echo -e "\n${WHITE}$authorFile${NC} created\nIn order to continue, copy the updated author data after the ${WHITE}^${NC}\n"
    echo -e "${RED}Example 1${NC} changing author data\n${WHITE}pickle,pickle,pickle@gmail.com,pickle@gmail.com^${GREEN}yoda,yoda,yoda@gmail.com,yoda@gmail.com\n"
    echo -e "${RED}Example 2${NC} data remains the same\n${WHITE}pickle,pickle,pickle@gmail.com,pickle@gmail.com^${NC}\n"
    echo -e "${NC}Run the script again once completed"
}

findAuthors () {
    # $1 is the directory of the repo
    # This function will find all current authors in the repos provided as a list

    cd $1
    # get all author and commiter data, then replace any spaces with '%'
    # bc bash CANNOT handle spaces
    # then remove duplicates
    local commiters=($(git log --pretty="format:%aN,%cN,%aE,%cE" | sed 's/ /%/g' | sort -u))
    cd $currentDir

    # merge two arrays together, global one with local one
    authors=("${authors[@]}" "${commiters[@]}")
}

checkAuthorFile () {
    while read line; do
        # if line does not end with ^
        if [ "${line: -1}" != "^" ]; then
            checkAuthorLine "${line}"
        fi
    done < "${authorFile}"
}

checkAuthorLine () {
    # takes line of author file as input
    # line is expected to be in modified form - example
    # pickle,pickle,pickle@gmail.com,pickle@gmail.com^yoda,yoda,yoda@gmail.com,yoda@gmail.com
    # sed is to remove space
    local numArrow=$(grep -o "^" <<<"$1" | wc -l | sed 's/ //g')
    local numComma=$(grep -o "," <<<"$1" | wc -l | sed 's/ //g')

    #echo $numComma $numArrow $1
    if [ "$numArrow" != "1" ]; then
        echo -e "${RED}Error, line is incorrectly formatted\n${WHITE}$1${NC}"
        exit
    fi
    if [ "$numComma" != "6" ]; then
        echo -e "${RED}Error, line is incorrectly formatted\n${WHITE}$1"
        exit
    fi
    
}

main