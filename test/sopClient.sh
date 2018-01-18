#!/usr/bin/env bash

# Function to output usage information
usage() {
  cat <<EOF
Usage: ${0##*/} [OPTION...] IP PORT
Connect to a SOP server at IP:PORT and send each line read from STDIN

Options:
  -h	 display this help text and exit
  -s SEC sleep SEC seconds between lines transmitted. SEC can take any value
         accepted by the sleep command. Defaults to 0.1 seconds.

Example:
  ${0##*/} 192.168.56.11 9001
  ${0##*/} -s 1 192.168.56.11 9001
EOF
  exit 1 >&2
}
# Print an error message
error() {
	echo "${0##*/}: $*" >&2
	exit 1
}

SLEEP=0.1
while getopts "hs:" option
do
	case $option in
		s) SLEEP=$OPTARG;;
		\?) usage;;
	esac
done

shift $(( $OPTIND - 1 ))

if [[ $# -ne 2 ]]; then
	usage
fi

IP=$1
PORT=$2

while read line; do
	echo -n "$line";
	sleep $SLEEP;
done | nc $IP $PORT
