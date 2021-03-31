#!/bin/sh

# Install hub extension for git
apt install hub
mkdir ~/configbackup
cd ~/configbackup

# List default directories and ask user to add more
printf Default directories are listed below
printf /example/default1;example/default2
read -p "Hello, would you like to add any directories?\n y/n:" addDir

if [ $addDir = "y" ] || [ $addDir = "Y" ]  ; then
# Prompt user for directories
    read -p "List directories, separated by ; for more than one directory:" directories
    if [ $addDir = "n" ] || [ $addDir = "N" ]; then
    # If no, exit loop
    return
    fi
# If not yes or no, exit 
else
    printf "\nPlease enter y or n:"
fi

# Add directories to list
printf $directories | tr ";" "\n" >> ~/configbackup/directories.txt

# Copy directories to folder in home directory
cat ./directories.txt | while read line || [[ -n $line]]
do
    rsync -avzh --progress $line ~/configbackup
done

# Add directories.txt to ignore list
touch ~/configbackup/.gitignore 
printf "directories.txt" >> ~/configbackup/.gitignore

# Create repo and push it
git init
git add .
git commit -m "First backup."
hub create
git push -u origin HEAD

# Add cronjob that backs up on reboot
while read -p "What user would you like to add the cronjob under?" cronuser
do
    crontab -l -u $cronuser | cat - ./syncbackup | crontab -u $cronuser -
    crontab -l -u $cronuser | cat - ./gitbackup | crontab -u $cronuser -
done