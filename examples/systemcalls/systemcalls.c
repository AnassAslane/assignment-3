#include "systemcalls.h"

/**
 * @param cmd the command to execute with system()
 * @return true if the command in @param cmd was executed
 *   successfully using the system() call, false if an error occurred,
 *   either in invocation of the system() call, or if a non-zero return
 *   value was returned by the command issued in @param cmd.
*/
bool do_system(const char *cmd)
{


    // Execute the command using system() and check if it returns 0
    int status = system(cmd);

    // Return true if command executed successfully (status == 0), otherwise false
    return (status == 0);
    return true;
}

/**
* @param count -The numbers of variables passed to the function. The variables are command to execute.
*   followed by arguments to pass to the command
*   Since exec() does not perform path expansion, the command to execute needs
*   to be an absolute path.
* @param ... - A list of 1 or more arguments after the @param count argument.
*   The first is always the full path to the command to execute with execv()
*   The remaining arguments are a list of arguments to pass to the command in execv()
* @return true if the command @param ... with arguments @param arguments were executed successfully
*   using the execv() call, false if an error occurred, either in invocation of the
*   fork, waitpid, or execv() command, or if a non-zero return value was returned
*   by the command issued in @param arguments with the specified arguments.
*/

bool do_exec(int count, ...)
{
    va_list args;
    va_start(args, count);
    char * command[count+1];
    int i;
    for(i=0; i<count; i++)
    {
        command[i] = va_arg(args, char *);
    }
    command[count] = NULL;
    // this line is to avoid a compile warning before your implementation is complete
    // and may be removed
    command[count] = command[count];

{
    va_list args;
    va_start(args, count);
    char *command[count + 1];
    int i;

    // Collect arguments into the command array
    for (i = 0; i < count; i++) {
        command[i] = va_arg(args, char *);
    }
    command[count] = NULL;

    // Fork to create a child process
    pid_t pid = fork();
    if (pid == -1) {
        // Fork failed, return false
        va_end(args);
        return false;
    } else if (pid == 0) {
        // Child process: execute the command
        execv(command[0], command);

        // If execv fails, return false
        perror("execv failed");
        _exit(1); // Exit child process with error
    } else {
        // Parent process: wait for the child to finish
        int status;
        waitpid(pid, &status, 0);
        
        // Return true if the command executed successfully
        va_end(args);
        return WIFEXITED(status) && WEXITSTATUS(status) == 0;
    }
}

    va_end(args);

    return true;
}

/**
* @param outputfile - The full path to the file to write with command output.
*   This file will be closed at completion of the function call.
* All other parameters, see do_exec above
*/
bool do_exec_redirect(const char *outputfile, int count, ...)
{
    va_list args;
    va_start(args, count);
    char *command[count + 1];
    int i;

    // Collect arguments into the command array
    for (i = 0; i < count; i++) {
        command[i] = va_arg(args, char *);
    }
    command[count] = NULL;

    // Open the output file for writing (create it if it doesn't exist, truncate if it does)
    int fd = open(outputfile, O_WRONLY | O_CREAT | O_TRUNC, S_IRUSR | S_IWUSR);
    if (fd == -1) {
        perror("Failed to open output file");
        va_end(args);
        return false;
    }

    // Fork to create a child process
    pid_t pid = fork();
    if (pid == -1) {
        // Fork failed, return false
        close(fd);
        va_end(args);
        return false;
    } else if (pid == 0) {
        // Child process: redirect stdout to the output file
        if (dup2(fd, STDOUT_FILENO) == -1) {
            perror("Failed to redirect stdout");
            close(fd);
            _exit(1);
        }
        close(fd);

        // Execute the command
        execv(command[0], command);

        // If execv fails, return false
        perror("execv failed");
        _exit(1);
    } else {
        // Parent process: wait for the child to finish
        int status;
        waitpid(pid, &status, 0);

        // Return true if the command executed successfully
        close(fd);
        va_end(args);
        return WIFEXITED(status) && WEXITSTATUS(status) == 0;
    }
}
