#!/bin/bash

# Check if both arguments are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: Both the file path and the text string must be provided."
    exit 1
fi

# Assign the arguments to variables
writefile="$1"
writestr="$2"

# Create the directory structure if it does not exist
dirpath=$(dirname "$writefile")

# Check if the directory exists, if not, create it
if [ ! -d "$dirpath" ]; then
    echo "Directory does not exist, creating it: $dirpath"
    mkdir -p "$dirpath"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create directory $dirpath."
        exit 1
    fi
fi

# Write the text string to the file, overwriting any existing file
echo "$writestr" > "$writefile"

# Check if the file was created successfully
if [ $? -eq 0 ]; then
    echo "File '$writefile' created successfully with content: '$writestr'"
else
    echo "Error: Could not create or write to the file '$writefile'."
    exit 1
fi
