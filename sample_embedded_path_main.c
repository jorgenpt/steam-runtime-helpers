/* Sample for how to set up the steam runtime dependencies if your
 * application uses DT_RPATH to direct the dynamic loader to the
 * steam-runtime directory.
 *
 # Copyright (C) 2014 Jørgen P. Tjernø <jorgenpt@gmail.com>
 # This script is licensed under the zlib license, which can be found in
 # the LICENSE file.
 */

#include <stdlib.h> // For malloc, realloc
#include <unistd.h> // For readlink
#include <string.h> // For strrchr
#include <stdio.h>  // For snprintf, printf
#include <limits.h> // For PATH_MAX

static const char *steamRuntimeRelativePath = "steam-runtime";

char* exeDir();

int main()
{
    if (!getenv("STEAM_RUNTIME"))
    {
        char *baseDir = exeDir();
        if (!baseDir)
        {
            fprintf(stderr, "ERROR: Unable to determine executable directory!\n");
            return 1;
        }

        int runtimePathSize = strlen(baseDir) + strlen(steamRuntimeRelativePath) + 1 /* for the nul byte */;
        char *runtimePath = (char*)malloc(runtimePathSize);
        snprintf(runtimePath, runtimePathSize, "%s%s", baseDir, steamRuntimeRelativePath);
        free(baseDir);

        printf("Setting STEAM_RUNTIME to '%s'\n", runtimePath);
        setenv("STEAM_RUNTIME", runtimePath, 1);
    }

    // TODO: Insert application code here.

    return 0;
}

// TODO: Fallbacks could be argv[0], and searching PATH if argv[0] does
// not contain a slash.
char* exeDir()
{
    char *exePath = (char*)malloc(PATH_MAX);

    int len = readlink("/proc/self/exe", exePath, PATH_MAX);
    if (len == -1)
        return NULL;

    // readlink() doesn't null terminate its output.
    exePath[len] = '\0';

    char *lastSlash = strrchr(exePath, '/');
    if (!lastSlash)
        return NULL;

    // Strip everything after the last slash.
    *(lastSlash + 1) = '\0';
    exePath = realloc(exePath, lastSlash - exePath + 1);

    return exePath;
}
