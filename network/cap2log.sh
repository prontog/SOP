#!/usr/bin/env bash

# Function to output usage information
usage() {
  cat <<EOF
Usage: ${0##*/} [OPTION] CAP_FILE...
Extract SOP message information from CAP_FILEs in the log format specified by
$SOP/specs/sopsrv_log.csv

Options:
  -h	display this help text and exit
  -v	increase verbosity (stderr). A single -v will show critical, error, info
        and debug messages. Double -v will show trace messages as well. Note
        that double -v is VERY verbose. Use for troubleshooting a dissector.

Example:
  ${0##*/} -v sop.pcapng
EOF
  exit 1 >&2
}
# Print an error message
error() {
	echo "${0##*/}: $*" >&2
	exit 1
}
verbose_echo() {
    if [[ $verbosity_level -ge 1 ]]; then
	   echo ${0##*/}: $* >&2
    fi
}
# Increase verbosity level. Default is quiet (0).
verbosity_level=0
increase_verbosity() {
    verbosity_level=$((verbosity_level + 1))
}

while getopts "hv" option
do
	case $option in
		v) increase_verbosity;;
		\?) usage;;
	esac
done

# By default redirect tshark's STDERR to /dev/null.
TSHARK_STDERR='2>/dev/null'
SOP_TRACE=
if [[ $verbosity_level -ge 1 ]]; then
	TSHARK_STDERR=
fi
if [[ $verbosity_level -ge 2 ]]; then
	SOP_TRACE="-o sop.trace:TRUE"
fi

shift $(( $OPTIND - 1 ))

if [[ $# -eq 0 ]]; then
	usage
fi

TSHARK_DISP_FILTER="-Y sop"
TSHARK_OUT_FIELDS="-e _ws.col.Time -e ip.src -e tcp.srcport -e ip.dst -e tcp.dstport -e sop.body"
TSHARK_CMD="tshark $SOP_TRACE $TSHARK_DISP_FILTER -T fields -E header=n -E separator=',' -E aggregator=';' -o gui.column.format:'Time,%Yt' $TSHARK_OUT_FIELDS"

set -o errexit

until [[ -z $1 ]]
do
	if [[ ! -f $1 ]]; then
		echo $1 is not a file >&2
	fi

	CAP_FILE=$1

    verbose_echo "processing $CAP_FILE" >&2

    # Update SOP specs env vars with the appropriate values.
    . $SOP/specs/sop_specs_path.sh $CAP_FILE

    # - Run tshark
    # - Split packaged messages into separte lines so that each line contains
    #   a single message.
	eval $TSHARK_CMD -r $CAP_FILE $TSHARK_STDERR | awk -v CAP_FILE="${CAP_FILE##*/}" '
	BEGIN {
		FS = ","
		OFS = " "
		# Add CRLF as record separator for Cygwin with Windows version of
        # tshark.
		RS = "\r\n|\n"
        # A regex to match a request message. At the moment only NO types are
        # supported. To add another one, use alternation (i.e. NO|CO).
        requestRegex = "^(NO)"
	}

	{
        # Keep up to millisecond precission.
		dateTime = gensub(/(\....).*$/, "\\1",1,$1)
        srcIPPort = sprintf("%-21s", $2 ":" $3)
        dstIPPort = sprintf("%-21s", $4 ":" $5)
        # Message types and clientIds are split into arrays.
		split($6, messages, ";")

		for(i in messages) {
            # Set ipPort with the SOP clients IP and Port.
            if (match(messages[i], requestRegex)) {
                serverIpPort = srcIPPort
                direction = "<"
                clientIpPort = dstIPPort
            } else {
                serverIpPort = dstIPPort
                direction = ">"
                clientIpPort = srcIPPort
            }
			print dateTime, serverIpPort, direction, clientIpPort, messages[i]
		}
	}'

	shift
done
