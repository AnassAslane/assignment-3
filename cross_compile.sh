#!/bin/bash

# Set up cross-compilation environment variables
# For example, using the ARM cross-compiler toolchain (adjust to your needs)
CROSS_COMPILE_PREFIX=arm-linux-gnueabihf-
CC=${CROSS_COMPILE_PREFIX}gcc
CXX=${CROSS_COMPILE_PREFIX}g++
AR=${CROSS_COMPILE_PREFIX}ar
AS=${CROSS_COMPILE_PREFIX}as
LD=${CROSS_COMPILE_PREFIX}ld
RANLIB=${CROSS_COMPILE_PREFIX}ranlib

# Navigate to the directory containing the source code
cd /path/to/source/directory

# Clean any previous build artifacts
echo "Cleaning previous build artifacts..."
make clean

# Set any necessary environment variables or flags for cross-compilation
export CROSS_COMPILE=${CROSS_COMPILE_PREFIX}
export ARCH=arm

# Cross-compile the writer utility
echo "Cross-compiling the writer application..."
make

# Verify that the binary was created successfully
if [ ! -f ./finder-app/writer ]; then
    echo "Error: Cross-compilation failed, writer binary not found!"
    exit 1
fi

echo "Cross-compilation successful, writer binary located at ./finder-app/writer"
