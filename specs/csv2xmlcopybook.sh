#!/bin/bash

# Function to output usage information
usage() {
  cat <<EOF
Usage: ${0##*/} -p PROT [OPTIONS] CSV_SPEC...
Converts CVS specs into XML Copybook format for RecordEditor. The XML Copybook is output to STDOUT.

Options:
  -p=PROT   the name to be used as RECORDNAME in the main RECORD tag as well
              as a prefix to the RECORDNAME of each child RECORD tag
  -h        display this text and exit
  -H=LEN    the length of the header field of each RECORD. This can be handy
              if you need to skip some characters from the start of the line

Example:
  ${0##*/} -p sop -H 10 OC.csv NO.csv TR.csv

EOF
  exit 1
}
# Function to print an error message and exit with exit code 1.
error() {
	echo "${0##*/}: $1" >&2
	exit 1
}

# Handle CLI options.
while getopts "hp:H:" option
do
case $option in
    p) PROTOCOL_NAME=$OPTARG;;
	H) HEADER_LEN=$OPTARG;;
	h) usage;;
	\?) exit 1;;
esac
done
shift $(( $OPTIND - 1 ))

if [[ -z $PROTOCOL_NAME ]]; then
    error "-p is not optional"
fi

if [[ $# -lt 1 ]]; then
    error "You need to pass at least one CSV_SPEC"
fi

set -o errexit

cat <<EOF
<?xml version="1.0" ?>
<RECORD RECORDNAME="$PROTOCOL_NAME" COPYBOOK="" DELIMITER="&lt;Tab&gt;" FILESTRUCTURE="Default" STYLE="0"
        RECORDTYPE="GroupOfRecords" LIST="Y" QUOTE="" RecSep="default">
	<RECORDS>
EOF

for s in $*; do
	if [[ ! -f $s ]]; then
		error "$s is not a file"
	fi

	SPEC_NAME=${s/.csv/}
cat <<EOF
		<RECORD RECORDNAME="$PROTOCOL_NAME: $SPEC_NAME" COPYBOOK="" DELIMITER="&lt;Tab&gt;"
		        DESCRIPTION="$PROTOCOL_NAME: $SPEC_NAME" FILESTRUCTURE="Default" STYLE="0" RECORDTYPE="RecordLayout"
			LIST="N" QUOTE="" RecSep="default" TESTFIELD="MessageType" TESTVALUE="$SPEC_NAME">
			<FIELDS>
EOF

	if [[ $HEADER_LEN -ne 0 ]]; then
		echo '				<FIELD NAME="Header"  POSITION="1" LENGTH="'$HEADER_LEN'" TYPE="Char"/>'
	fi

	awk -v header_len=$HEADER_LEN '
	BEGIN {
		FS = ","
		f_position = header_len + 1
	}
	NR != 1 {
		f_name = $1
		f_length = $2
		printf "\t\t\t\t<FIELD NAME=\"%s\"  POSITION=\"%d\" LENGTH=\"%d\" TYPE=\"Char\"/>\n", f_name, f_position, f_length
		f_position += f_length
	}
	' $s
cat <<EOF
			</FIELDS>
		</RECORD>
EOF
done

cat <<EOF
	</RECORDS>
</RECORD>
EOF
