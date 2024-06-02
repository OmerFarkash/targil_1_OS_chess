/* Omer farkash
   I.D 211466362 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
#include <errno.h>

#define MAX_COMMANDS 100
#define MAX_COMMAND_LENGTH 100

char *history[MAX_COMMANDS];
int history_count = 0;

// save the command in the history array
void add_to_history(const char *cmd) {
    if (history_count < MAX_COMMANDS) {
        history[history_count++] = strdup(cmd);
    }
}

// print the history array
void print_history() {
    for (int i = 0; i < history_count; i++) {
        printf("%s\n", history[i]);
    }
}

// change the current directory
void change_directory(char *path) {
    if (chdir(path) != 0) {
        perror("cd failed");
    }
}

// print the current directory
void print_working_directory() {
    char cwd[1024];
    if (getcwd(cwd, sizeof(cwd)) != NULL) {
        printf("%s\n", cwd);
    } else {
        perror("pwd failed");
    }
}

// execute the command
void execute_command(char **args, char **env_paths) {
    pid_t pid = fork();
    if (pid < 0) {
        perror("fork failed");
        exit(EXIT_FAILURE);
    } else if (pid == 0) {
        // Child process
        char *command = args[0];
        if (command[0] == '.' || command[0] == '/') {
            execv(command, args);
        } else {
            for (int i = 0; env_paths[i] != NULL; i++) {
                char cmd_path[1024];
                snprintf(cmd_path, sizeof(cmd_path), "%s/%s", env_paths[i], command);
                execv(cmd_path, args);
            }
            // If command is in PATH
            execvp(command, args);  
        }
        perror("exec failed");
        exit(EXIT_FAILURE);
    } else {
        // Parent process
        int status;
        if (waitpid(pid, &status, 0) == -1) {
            perror("waitpid failed");
        }
    }
}

int main(int argc, char *argv[]) {
    char *env_paths[MAX_COMMANDS] = { NULL };
    int env_paths_count = 0;

    for (int i = 1; i < argc; i++) {
        env_paths[env_paths_count++] = argv[i];
    }

    char *path_env = getenv("PATH");
    char *path_token = strtok(path_env, ":");
    while (path_token != NULL) {
        env_paths[env_paths_count++] = path_token;
        path_token = strtok(NULL, ":");
    }
    env_paths[env_paths_count] = NULL;

    while (1) {
        printf("$ ");
        fflush(stdout);

        char cmd[MAX_COMMAND_LENGTH];
        // EOF or read error
        if (!fgets(cmd, sizeof(cmd), stdin)) {
            break;  
        }
        
        // Remove trailing newline
        cmd[strcspn(cmd, "\n")] = 0;  
        // Ignore empty commands
        if (strlen(cmd) == 0) {
            continue;
        }

        add_to_history(cmd);

        char *args[MAX_COMMAND_LENGTH];
        int arg_count = 0;
        char *token = strtok(cmd, " ");
        while (token != NULL) {
            args[arg_count++] = token;
            token = strtok(NULL, " ");
        }
        args[arg_count] = NULL;

        if (strcmp(args[0], "exit") == 0) {
            break;
        } else if (strcmp(args[0], "cd") == 0) {
            if (arg_count < 2) {
                fprintf(stderr, "cd: missing argument\n");
            } else {
                change_directory(args[1]);
            }
        } else if (strcmp(args[0], "pwd") == 0) {
            print_working_directory();
        } else if (strcmp(args[0], "history") == 0) {
            print_history();
        } else {
            execute_command(args, env_paths);
        }
    }

    return 0;
}
