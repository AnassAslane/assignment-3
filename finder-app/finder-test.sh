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

# Loop to create numfiles files using writer.sh
for ((i = 1; i <= numfiles; i++)); do
    # Construct the filename
    writefile="/tmp/aeld-data/${username}${i}.txt"
    
    # Call writer.sh to create the file with writestr content
    ./finder-app/writer.sh "$writefile" "$writestr"
done

# Run the finder.sh script and capture the output
output=$(./finder-app/finder.sh /tmp/aeld-data "$writestr")

# Prepare the expected output
expected_output="The number of files are $numfiles and the number of matching lines are $numfiles"

# Compare the output with expected output
if [ "$output" == "$expected_output" ]; then
    echo "success"
else
    echo "error"
fi

