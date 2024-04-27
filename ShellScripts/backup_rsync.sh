#!/bin/bash

# Check to make sure the user has entered exactly two arguments.

if [ $# -ne 2 ]
then
        echo "Usage: backup.sh <source_directory> <target_dirctory>"
        echo "Please try again."
        exit 1
fi

# Check if the source directory exists
if [ ! -d $1 ]
then
        echo "The source directory $1 does not exist. Backup halted"
        echo "Please try again."
        exit 1
fi

# Check if the target directory exists
if [ ! -d $2 ]
then
        echo "The target directory $2 does not exist."
        echo "Creating target_dirctory..."
        mkdir -p $2
fi


# Check to see if rsync is installed.
if ! command -v rsync > /dev/null 2>&1
then
        echo "This script requires rsync to be installed."
        echo "Please user your distribution's package maneger to install it and try again."
        exit 2
fi

# Capture the current date and time stamp, and store it.
current_date=$(date +"%Y-%m-%d")
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

# Starting the backup process
echo "Starting backup for $timestamp" | tee -a $2/backup_history.log

rsync_options="-avb --backup-dir $2/$timestamp --delete --dry-run" # $2 target_dirctory
$(which rsync) $rsync_options $1 $2/curret_dir >> $2/backup_$current_date.log

# Check if rsync was successful
if [ $? -eq 0 ]; then
    echo "Backup successful for $timestamp" | tee -a $2/backup_history.log
else
    echo "Backup failed for $timestamp. Check log file $2/backup_history.log for errors." | tee -a $2/backup_history.log
    exit 1
fi

echo "Backup process completed." | tee -a $2/backup_history.log