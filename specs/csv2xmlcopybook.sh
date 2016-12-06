#!/bin/bash

# Function to output usage information
usage() {
  cat <<EOF
Usage: ${0##*/} HEADER_LEN RECORDNAME CSV_SPEC...
Converts CVS specs into XML Copybook format for RecordEditor.

HEADER_LEN is the length of the header part of the line.
RECORDNAME is the name of the record in the RecordEditor XML layout.
EOF
  exit 1
}

if [[ $# -lt 4 ]]; then
    usage
fi

HEADER_LEN=$1
shift
RECORDNAME=$1
shift

set -o errexit

cat <<EOF
<?xml version="1.0" ?>
<RECORD RECORDNAME="$RECORDNAME" COPYBOOK="" DELIMITER="&lt;Tab&gt;" FILESTRUCTURE="Default" STYLE="0" 
        RECORDTYPE="GroupOfRecords" LIST="Y" QUOTE="" RecSep="default">
	<RECORDS>
EOF

for s in $*; do
	SPEC_NAME=${s/.csv/}
cat <<EOF
		<RECORD RECORDNAME="$RECORDNAME: $SPEC_NAME" COPYBOOK="" DELIMITER="&lt;Tab&gt;" 
		        DESCRIPTION="$RECORDNAME: $SPEC_NAME" FILESTRUCTURE="Default" STYLE="0" ECORDTYPE="RecordLayout"
			LIST="N" QUOTE="" RecSep="default" TESTFIELD="MessageType" TESTVALUE="$SPEC_NAME">
			<FIELDS>
				<FIELD NAME="Header"  POSITION="1" LENGTH="$HEADER_LEN" TYPE="Char"/>
EOF
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