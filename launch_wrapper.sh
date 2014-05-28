#!/bin/bash
# Copyright (C) 2014 Jørgen P. Tjernø <jorgenpt@gmail.com>
# This script is licensed under the zlib license, which can be found in
# the LICENSE file.

# A wrapper script for your game that'll make sure your game is launched
# inside the steam-runtime. Name the script `$foo` or `$foo.sh`, and
# then name your game binary $foo.bin, and the script will figure out
# what binary to launch (where $foo is any valid application name.)
#
# You can launch it with --gdb to launch the application inside gdb, and
# with --check-program to make sure that all the dependencies of your
# application are satisfied by the steam-runtime.
#
# See this blog post for details:
# http://jorgen.tjer.no/post/2014/05/27/linux-games-at-full-steam-ahead/


# Path to the steam-runtime, relative to the directory where the
# executable lives.
JPT_STEAM_RUNTIME_LOCATION='steam-runtime'

# Figure out where this script lives.
exedir="$(cd "$(dirname "$0")" && pwd)"
# If this script is named `foo.sh' or just `foo', we execute `foo.bin'
exename="$(basename "$0" ".sh").bin"

if [ "$1" == "--check-program" ]; then
    exec "$exedir/$JPT_STEAM_RUNTIME_LOCATION/scripts/check-program.sh" "$exedir/$exename"
fi

# If the steam runtime is not already configured, re-exec ourself with
# the steam-runtime we expect to find in $JPT_STEAM_RUNTIME_LOCATION.
if [ -z "$STEAM_RUNTIME" ]; then
    if [ ! -z "$JPT_ATTEMPTED_REEXEC" ]; then
        echo "ERROR: Reexecuted in runtime, but STEAM_RUNTIME is unset!" >&2
        exit 1
    fi

    export JPT_ATTEMPTED_REEXEC=1
    exec "$exedir/$JPT_STEAM_RUNTIME_LOCATION/run.sh" "$0" "$@"
fi

# We support launching with --gdb to load the executable inside gdb,
# setting up the steam-runtime environment for the debugged process.
if [ "$1" == "--gdb" ]; then
    shift

    # Don't force GDB to load things from LD_LIBRARY_PATH, but instruct it to
    # tell the inferior process that it should.
    argsfile="$(mktemp $USER.$exename.gdb.XXXX)"
    echo set env LD_LIBRARY_PATH=$LD_LIBRARY_PATH >> "$argsfile"
    echo show env LD_LIBRARY_PATH >> "$argsfile"
    unset LD_LIBRARY_PATH

    gdb -x "$argsfile" --args "$exedir/$exename" "$@"
    exitcode=$?
    rm "$argsfile"
else
    "$exedir/$exename" "$@"
    exitcode=$?
fi

exit $exitcode
