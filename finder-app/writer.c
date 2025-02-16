#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <syslog.h>
#include <errno.h>

// Function to write the string to the file
void write_to_file(const char *string, const char *file_path) {
    FILE *file = fopen(file_path, "w"); // Open file for writing
    if (file == NULL) {
        // Log error if the file cannot be opened
        syslog(LOG_ERR, "Failed to open file %s for writing: %s", file_path, strerror(errno));
        exit(EXIT_FAILURE);
    }

    // Write the string to the file
    if (fputs(string, file) == EOF) {
        // Log error if writing to the file fails
        syslog(LOG_ERR, "Failed to write to file %s: %s", file_path, strerror(errno));
        fclose(file);
        exit(EXIT_FAILURE);
    }

    // Log successful writing to the file with LOG_DEBUG level
    syslog(LOG_DEBUG, "Writing \"%s\" to %s", string, file_path);

    // Close the file after writing
    fclose(file);
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        // If incorrect number of arguments, log an error and exit
        syslog(LOG_ERR, "Usage: %s <string> <file>", argv[0]);
        exit(EXIT_FAILURE);
    }

    const char *string_to_write = argv[1];
    const char *file_path = argv[2];

    // Open syslog for logging
    openlog("writer", LOG_PID | LOG_CONS, LOG_USER);

    // Call the function to write the string to the file
    write_to_file(string_to_write, file_path);

    // Close syslog
    closelog();

    return EXIT_SUCCESS;
}
