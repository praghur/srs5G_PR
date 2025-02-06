#!/bin/bash
while true; do
    ping -c 1 10.45.1.10
    ping -c 1 10.45.2.10
    sleep 60
done
