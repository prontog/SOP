#!/bin/bash

# Function to output usage information
usage() {
  cat <<EOF
Usage: ${0##*/} SOP_LOG
Calculate transaction latency from a SOP log.

NOTE:For this script to work, the directory with the CSV specs
     should be set to env var SOP_SPECS_PATH.
EOF
  exit 1
}

SCRIPT_DIR=${0%/*}
if [[ $OSTYPE = cygwin ]]; then
	SCRIPT_DIR="$(cygpath -m "$SCRIPT_DIR")"
fi

SOP_LOG=$1
if [[ ! -f $SOP_LOG ]]; then
    usage
fi

if [[ ! -d $SOP_SPECS_PATH ]]; then
	echo "Invalid SOP_SPECS_PATH [$SOP_SPECS_PATH]"
	usage
fi

set -o errexit

FNAME=$(basename $SOP_LOG)
SOP_LOG_TMP=${FNAME}.tmp
# 1) Keep only the lines with messages.
# 2) Add date to the beggining .
sed -n '/ [<>?] /p' $SOP_LOG > $SOP_LOG_TMP

# Hack to avoid the "invalid multibyte string" error from function substring.
export LANG=C
export SOP_LOG=$SOP_LOG_TMP
Rscript ${SCRIPT_DIR}/sop_latency.R

rm -f $SOP_LOG_TMP
