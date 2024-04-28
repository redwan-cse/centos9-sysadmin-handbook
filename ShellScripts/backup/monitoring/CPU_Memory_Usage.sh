#!/bin/bash

# Script to monitor CPU and Memory usage

while true; do
    # Get CPU usage percentage
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    
    # Get Memory usage percentage
    mem_usage=$(free | awk '/Mem/{printf("%.2f"), $3/$2*100}')

    # Print current date/time and resource usage
    echo "$(date +"%Y-%m-%d %H:%M:%S") - CPU: $cpu_usage% | Memory: $mem_usage%"
    
    # Sleep for 1 minute
    sleep 60
done
