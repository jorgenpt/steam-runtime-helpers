#!/bin/bash -e
# Copyright (C) 2014 Jørgen P. Tjernø <jorgenpt@gmail.com>
# This script is licensed under the zlib license, which can be found in
# the LICENSE file.

# A small helper script that downloads the latest version of the steam
# runtime into the directory the script lives in, unless you already
# have the current version.

function has_tool() { which "$1" >&- 2>&-; }
function fatal() { echo "$@" >&2; exit 1; }

RUNTIME_URL_BASE="http://media.steampowered.com/client/runtime"
RUNTIME_MD5_URL="${RUNTIME_URL_BASE}/steam-runtime-release_latest.tar.xz.md5"

BASEDIR="$(cd "$(dirname "$0")" && pwd)"

LOCAL_RUNTIME="${BASEDIR}/$(basename "$RUNTIME_MD5_URL" ".md5")"

# Check for a working md5 tool.
MD5TOOL="md5sum"
if ! has_tool "$MD5TOOL"; then
    if ! has_tool md5; then
        fatal "Cannot find md5 command line tool (looked for 'md5' and 'md5sum')."
    fi

    MD5TOOL="md5 -r"
fi

if ! has_tool curl; then
    fatal "Cannot find curl"
fi

# Download the .md5 file that has the metadata.
echo "Retrieving information about latest runtime."
RUNTIME_INFO=$(curl -s "$RUNTIME_MD5_URL")
RUNTIME_MD5=$(awk '{print $1}' <<<"$RUNTIME_INFO")
RUNTIME_FILE=$(awk '{print $2}' <<<"$RUNTIME_INFO")
RUNTIME_URL="${RUNTIME_URL_BASE}/${RUNTIME_FILE}"

# If we already have a runtime, checksum it to see if it needs updating.
if [ -f "$LOCAL_RUNTIME" ]; then
    echo "Found local copy of the runtime, checking if it's up to date."
    LOCAL_MD5=$($MD5TOOL "$LOCAL_RUNTIME" | awk '{print $1}')
    if [ "$LOCAL_MD5" == "$RUNTIME_MD5" ]; then
        echo "Local runtime is up to date."
        exit 0
    else
        echo "Local runtime is out of date."
    fi
fi

# Do the actual download
echo "Downloading new runtime (from ${RUNTIME_FILE})."
curl -s -o "${LOCAL_RUNTIME}.tmp" "$RUNTIME_URL"

# Verify that we got the MD5 we expected.
LOCAL_MD5=$($MD5TOOL "${LOCAL_RUNTIME}.tmp" | awk '{print $1}')
if [ "$LOCAL_MD5" != "$RUNTIME_MD5" ]; then
    fatal "Download has invalid checksum! Aborting!"
fi

# Attempt a p4 edit in case this is a Perforce repository.
if has_tool p4; then
    p4 edit "${LOCAL_RUNTIME}" >/dev/null 2>&1 || true
fi

# Move it in place.
mv "${LOCAL_RUNTIME}.tmp" "${LOCAL_RUNTIME}"

echo "All done!"
