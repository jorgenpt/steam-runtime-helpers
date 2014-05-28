#!/bin/bash -e
# Copyright (C) 2014 Jørgen P. Tjernø <jorgenpt@gmail.com>
# This script is licensed under the zlib license, which can be found in
# the LICENSE file.

# Helper script for extracting the steam-runtime that:
#  - Strips unused parts of the runtime (documentation)
#  - Allows you to extract a single architecture
#  - Extracts it to a named directory rather than one that contains the
#    runtime release date.
#
# Usage:
#  $ ./extract_runtime.sh <path to steam-runtime-release_latest.tar.xz> <amd|i386|all> <output directory>

function fatal() { echo "$@" >&2; exit 1; }

if [ $# -lt 3 ]; then
    fatal "Usage: $0 <steam-runtime path> <amd64|i386|all> <output directory>" >&2
fi

LOCAL_RUNTIME="$1"
ARCH="$2"
OUTPUT="$3"

# Validate arguments.
if [ ! -f "$LOCAL_RUNTIME" ]; then fatal "Unable to find runtime '$LOCAL_RUNTIME'"; fi
case "$ARCH" in
    amd64) ;; i386) ;; all) ;;
        *)
            fatal "Architecture '$ARCH' is not amd64, i386, or all." ;;
esac
if [ -e "$OUTPUT" ] && ! rmdir "$OUTPUT" >/dev/null 2>&1; then
    fatal "Output directory '$OUTPUT' already exists and is non-empty, cowardly refusing to extract."
fi

# Create a file containing patterns to not extract
EXCLUSIONSFILE="$(mktemp $USER.extract_runtime.exclusions.XXXX)"

# Exclude man pages & docs.
echo '*/usr/share/doc' >>"$EXCLUSIONSFILE"
echo '*/usr/share/man' >>"$EXCLUSIONSFILE"

# Exclude the other arch.
case "$ARCH" in
    amd64) echo 'i386/*'  >>"$EXCLUSIONSFILE" ;;
     i386) echo 'amd64/*' >>"$EXCLUSIONSFILE" ;;
esac

echo "Extracting runtime for $ARCH from $LOCAL_RUNTIME into $OUTPUT"

mkdir -p "$OUTPUT"

# Strip the date-specific prefix, exclude our various patterns, and
# change directory to $OUTPUT before extracting.
tar --strip-components 1 \
    -X "$EXCLUSIONSFILE" \
    -C "$OUTPUT" \
    -xJf "$LOCAL_RUNTIME"

rm -f "$EXCLUSIONSFILE"
