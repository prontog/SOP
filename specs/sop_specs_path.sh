#!/usr/bin/env bash

# Function to output usage information
usage() {
  cat <<EOF
Usage: source ${0##*/} [OPTION] FILE
Update SOP_SPEC_PATH environment variable to the directory best-matching the
filename.

It looks for a DATE in the filename with either the format YYYY-MM-DD
or YYYY_MM_DD. Then it looks in $SOP/specs/versions.csv for the latest version
at that DATE. Finally it updates SOP_SPEC_PATH with the directory with the specs
of that version of SOP.

If no file is given or the filename has no DATE in it, then SOP_SPEC_PATH is left
unchanged.

$SOP/specs/versions.txt is a TAB separated file with columns for VERSION,
RELEASE_DATE and INFO. If the directory $SOP/specs/VERSION is missing then
SOP_SPEC_PATH is set to $SOP/specs/.

NOTE that this script should only be sourced!

Options:
  -h	display this help text and exit
EOF
  exit 1
}
# Function to print an error message and exit with exit code 1.
error() {
	echo "${0##*/}: $1" > &2
	exit 1
}

while getopts "h" option
do
	case $option in
		h) usage;;
        *) exit 1;;
	esac
done

shift $(( $OPTIND - 1 ))

if [[ $# -eq 0 ]]; then
    error "No file given, SOP_SPECS_PATH is left unchanged."
fi

FILE=$1
DATE=$(echo $FILE | sed -nr 's/.*([[:digit:]]{4}[_-][[:digit:]]{2}[_-][[:digit:]]{2}).*/\1/p')

if [[ -z $DATE ]]; then
    error "No date found in $FILE, SOP_SPECS_PATH is left unchanged."
fi

# Find the latest version at DATE. It concats vrsion.csv and a dummy line with
# the DATE and sort the lines according to the release dates. Finally pick the line
# above the DATE.
version_line=$({
    cat $SOP/specs/versions.csv;
    printf "_\t%s\t_" $DATE;
} | sort -k 2,2 | grep -B1 "^_[[:space:]]$DATE[[:space:]]_$" | head -1)

read spec_dir release_date info < <(echo $version_line)
if [[ -d "$SOP/specs/$spec_dir" ]]; then
    SOP_SPECS_PATH="$SOP/specs/$spec_dir/"
    echo "Updated SOP_SPECS_PATH to $SOP_SPECS_PATH" >&2
else
    SOP_SPECS_PATH="$SOP/specs/"
fi
