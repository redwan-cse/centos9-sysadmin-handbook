#!/bin/bash

# Script to monitor Network traffic

while true; do
    # Get Network traffic
    rx_bytes=$(cat /proc/net/dev | grep 'eth0' | awk '{print $2}')
    tx_bytes=$(cat /proc/net/dev | grep 'eth0' | awk '{print $10}')

    # Convert bytes to human-readable format
    rx=$(echo "scale=2; $rx_bytes / 1024 / 1024" | bc)
    tx=$(echo "scale=2; $tx_bytes / 1024 / 1024" | bc)
    
    # Print current date/time and network traffic
    echo "$(date +"%Y-%m-%d %H:%M:%S") - RX: ${rx}MB | TX: ${tx}MB"
    
    # Sleep for 1 minute
    sleep 60
done
