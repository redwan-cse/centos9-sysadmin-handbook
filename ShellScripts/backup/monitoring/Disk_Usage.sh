#!/bin/bash

# Script to monitor Disk usage

while true; do
    # Get Disk usage percentage
    disk_usage=$(df -h / | awk 'NR==2 {print $5}')
    
    # Print current date/time and disk usage
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Disk Usage: $disk_usage"
    
    # Sleep for 5 minutes
    sleep 300
done
