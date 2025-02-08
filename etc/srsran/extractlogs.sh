#!/bin/bash

# Define the log file and output CSV file
log_file="/tmp/gnb1.log"
output_csv="/tmp/phy_logs.csv"

# Print the CSV header
echo "Log Line" > $output_csv

# Read the log file line by line
while IFS= read -r line; do
    # Check if the line contains "2025-02-", "sinr_ch_est", or "sinr_eq[sel]"
    if [[ $line == *"2025-02-"* || $line == *"sinr_ch_est"* || $line == *"sinr_eq[sel]"* ]]; then
        # Append the entire line to the CSV file
        echo "$line" >> $output_csv
    fi
done < "$log_file"

echo "Extraction complete. The CSV file is saved at $output_csv"
