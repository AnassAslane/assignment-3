#!/bin/bash

# Check if both arguments are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: Both the directory path and the search string must be provided."
    exit 1
fi

# Assign the arguments to variables
filesdir="$1"
searchstr="$2"

# Check if the provided filesdir is a directory
if [ ! -d "$filesdir" ]; then
    echo "Error: '$filesdir' is not a valid directory."
    exit 1
fi

# Find all files in the directory and its subdirectories
files=$(find "$filesdir" -type f)

# Initialize counters
file_count=0
matching_line_count=0

# Loop through the files
for file in $files; do
    # Increment the file count
    ((file_count++))

    # Search for the matching lines in each file and count them
    matching_lines=$(grep -c "$searchstr" "$file")
    matching_line_count=$((matching_line_count + matching_lines))
done

# Print the result
echo "The number of files are $file_count and the number of matching lines are $matching_line_count"
