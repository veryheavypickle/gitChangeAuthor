# gitChangeAuthor
This is a bash script that will iterate through git repositories and swap old author details for new ones

### How
1. Create a new directory called `repositories` and place all the repositories there
2. Run `./main.sh` which will create an `authors.txt`
3. Follow the instructions from the output of running the script to update `authors.txt`
4. Run `./main.sh` again to actually update the authors

### TODO
1. Fix bug where the same author can be repeated many times
