#!/bin/bash

# Function to run traceroute 50 times randomly within an hour and write results to a CSV file
run_traceroute() {
  for i in {1..50}
  do
    result=$(traceroute -U -q 10 -f 2 -m 2 -p 33435 10.45.2.10)
    echo "$(date), $result" >> traceroute_results.csv
    sleep $((RANDOM % 70 + 1))  # Sleep for a random time between 1 to 70 seconds
  done
}

# Initialize the CSV file with headers
echo "Timestamp, Traceroute Result" > traceroute_results.csv

# Run the traceroute function every hour for 24 hours
for hour in {1..24}
do
  run_traceroute
  sleep 3600  # Wait for an hour before the next set of runs
done
