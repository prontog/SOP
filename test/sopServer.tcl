#!/usr/bin/tclsh

# IMPORTANT: This file contains non-printable (invisible) characters SOH and
# ETX used by SOP. Make sure you edit it with an editor that can handle them.

if { $argc != 2 } {
    puts "usage: $argv0 IP PORT"
	puts "    example: $argv0 localhost 9001"
    exit 1
} else {
    set local_ip [lindex $argv 0]
    set local_port [lindex $argv 1]
}

# SOH + LEN fields
set HEADER_LEN 4
set TRAILER_LEN 1

# Logging proc.
proc log {message} {
    puts "[getTime]: $message"
}


# Get current time.
proc getTime {} {
	set t [clock milliseconds]
	return [format "%s.%03d" [clock format [expr {$t / 1000}] -format "%Y-%m-%d %T"] [expr {$t % 1000}]]
}

# Background errors handler. Necessary since we use non blocking I/O.
proc bgerror msg {
    # Copy this immediately, as �clock format� is implemented in Tcl internally
    set stackTrace $::errorInfo
    log "$msg\n$stackTrace"
}

proc getNextMsg { buffer } {
    global HEADER_LEN
    global TRAILER_LEN

    if { [string length $buffer] == 0 } {
		return ""
	}
	# Make sure the buffer starts with SOH.
	if { [string first \x01 $buffer]  != 0 } {
		log "Missing SOH field. Msg will be ignored. \[$buffer\]"
		#close $channel
		#exit 1
		return ""
	}
	# Read the LEN field.
	set nf [scan $buffer {%3d} len]
	if { $nf != 1 } {
		log "Missing LEN field. Msg will be ignored. \[$buffer\]"
		return ""
	}
	# Make sure the buffer has enough size for the whole message.
	set msgLen [expr $HEADER_LEN + $len + $TRAILER_LEN]
	if { [string length $buffer] != $msgLen } {
		log "Incomplete msg. Msg will be ignored. \[$buffer\]"
		return ""
	}
	# Make sure the message ends with ETX.
	if { [string compare [string index $buffer [expr $msgLen - 1]] \x03] != 0 } {
		log "Missing ETX field. Msg will be ignored. \[$buffer\]"
		#close $channel
		#exit 1
		return ""
	}

	# Return the message PAYLOAD. Remember TCL strings are zero indexed.
	return [string range $buffer [expr $HEADER_LEN] [expr $HEADER_LEN + $len - 1]]
}

proc readMsg { channel ip port } {
    global HEADER_LEN
	global TRAILER_LEN
	global msg_counter
	global ordnum_counter
    global local_ip
    global local_port

	if { [eof $channel] } {
		log "EOF on channel. Disconnecting from $ip:$port."
		close $channel
		set forever 0
		return
	}

	set buffer [read $channel]
	# The timestamp to be used for logging is saved here before processing the
	# messages.
	set timeStamp [getTime]
	set msg ""
    while {	[string length [set msg [getNextMsg $buffer]]] > 0 } {
		# Log each incoming message in a separate line even if it was packaged
		# in the same TCP segment with more messages.
		puts "$timeStamp [format {%-21s} $local_ip:$local_port] < [format {%-21s} $ip:$port] $msg"

		set msg_type [string range $msg 0 1]
		set responsePayload ""
		switch $msg_type {
			NO {
				set nf [scan $msg {%2s%c%3s%7s%12[ a-zA-Z0-9]%8s%16[ a-zA-Z0-9]%16[ a-zA-Z0-9]} msg_type side type volume symbol price clientId accountId]

				if { $nf != 8 } {
					log "Invalid msg format. Msg will be ignored."
					return 1
				}

				incr msg_counter
				incr ordnum_counter
				set responsePayload [format {OC%.6d%c%3s%7s%-12s%8s%-16s%-16s} $ordnum_counter $side $type $volume $symbol $price $clientId $accountId]
			}
			default {
				log "Unknown msg type \[$msg_type\]. Msg will be ignored."
				return 1
			}
		}

		set response [format {%.3d%s} [string length $responsePayload] $responsePayload]
		puts -nonewline $channel $response
		flush $channel
		puts "[getTime] [format {%-21s} $local_ip:$local_port] > [format {%-21s} $ip:$port] $responsePayload"

		set buffer [string range $buffer [expr $HEADER_LEN + [string length $msg] + $TRAILER_LEN] end]
	}
}

# Handle the connection.
proc acceptCon {channel ip port} {
	log "Connection from $ip:$port"

	fconfigure $channel -blocking 0
	# -buffering none -translation binary
	fileevent $channel readable [list readMsg $channel $ip $port]
}

# Save the PID to a file so that we can kill it if it runs in the background.
set pidFile [open $argv0.pid w]
puts $pidFile [pid]
close $pidFile

set msg_counter 0
set ordnum_counter 0
# Listen for connections.
socket -server acceptCon -myaddr $local_ip $local_port
log "Listening for SOP connections on $local_ip:$local_port"
vwait forever
