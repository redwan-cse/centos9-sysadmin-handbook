#!/bin/bash

# Define source and target folder locations
source_dir="/path/to/source/directory"
target_dir="/path/to/backup/directory"

# Check if the source directory exists
if [ ! -d $source_dir ]
then
    echo "The source directory $source_dir does not exist. Backup halted"
    echo "Please try again."
    exit 1
fi

# Check if the target directory exists
if [ ! -d $target_dir ]
then
    echo "The target directory $target_dir does not exist."
    echo "Creating target_dirctory..."
    mkdir -p $target_dir
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
echo "Starting backup for $timestamp" | tee -a $target_dir/backup_history.log

rsync_options="-avb --backup-dir $target_dir/$timestamp --delete --dry-run" # $target_dir target_dirctory
$(which rsync) $rsync_options $source_dir $target_dir/curret_dir >> $target_dir/backup_$current_date.log

# Check if rsync was successful
if [ $? -eq 0 ]; then
    echo "Backup successful for $timestamp" | tee -a $target_dir/backup_history.log
else
    echo "Backup failed for $timestamp. Check log file $target_dir/backup_history.log for errors." | tee -a $target_dir/backup_history.log
    exit 1
fi

echo "Backup process completed." | tee -a $target_dir/backup_history.log