#!/bin/bash

# Define source and target folder locations
source_dir="/path/to/source/directory"
target_dir="/path/to/backup/directory/monthly"

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

# Capture the current date and time stamp, and store it.
current_date=$(date +"%Y-%m-%d")
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

# Create a monthly gzip tar.gz backup
tar -czf "$target_dir/backup_$timestamp.tar.gz" "$source_dir" > "$target_dir/backup_$timestamp.log" 2>&1

# Check if gzip tar.gz backup was successful
if [ $? -eq 0 ]; then
    echo "Monthly backup successful for $timestamp"
else
    echo "Monthly backup failed for $timestamp. Check log file for errors."
    exit 1
fi

echo "Monthly backup process completed."