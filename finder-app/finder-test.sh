#!/bin/bash

# Default values
numfiles=10
writestr="AELD_IS_FUN"

# Check if arguments are provided, else use defaults
if [ ! -z "$1" ]; then
    numfiles=$1
fi

if [ ! -z "$2" ]; then
    writestr=$2
fi

# Create /tmp/aeld-data directory
mkdir -p /tmp/aeld-data

# Get the username from the conf/username.txt
username=$(cat /conf/username.txt)

# Loop to create numfiles files using the writer utility
for ((i = 1; i <= numfiles; i++)); do
    # Construct the filename
    writefile="/tmp/aeld-data/${username}${i}.txt"
    
    # Call the writer application to create the file with writestr content
    ./finder-app/writer "$writefile" "$writestr"
done

# Run the finder.sh script and capture the output (if necessary)
# Add any additional commands or actions if required below

