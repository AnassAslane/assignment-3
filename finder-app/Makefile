# Makefile for building the "writer" application

# Compiler settings
CC = $(CROSS_COMPILE)gcc
CFLAGS = -Wall -g  # Basic flags for compiling with debugging symbols
LDFLAGS =           # Linker flags (empty for now)

# File paths
SRC = finder-app/writer.c  # Path to the source file
OBJ = writer.o             # Object file for the source
OUT = writer               # Output binary file

# Default target
all: $(OUT)

# Rule for building the "writer" executable
$(OUT): $(OBJ)
	$(CC) $(OBJ) -o $(OUT) $(LDFLAGS)

# Rule for compiling the source file into an object file
$(OBJ): $(SRC)
	$(CC) $(CFLAGS) -c $(SRC)

# Clean target to remove generated files
clean:
	rm -f $(OUT) $(OBJ)

# Help target for user guidance
help:
	@echo "Makefile for building the writer application"
	@echo "Usage:"
	@echo "  make        # Builds the writer application using the native compiler"
	@echo "  make clean  # Removes the generated files"
	@echo "  make CROSS_COMPILE=aarch64-none-linux-gnu- # Cross-compiles the application"

.PHONY: all clean help
