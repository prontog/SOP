### Creating new logs/capture files

What I usually do to create new log files/capture file is (replace IP, PORT and INTERFACE with something valid):

1. Start a SOP server with `$SOP/test/sopServer.tcl IP PORT > sopsrv_$(date +%Y-%m-%d).log`
2. From another terminal, start *tshark* with a display filter with the protocol name: `tshark -i INTERFACE -f 'port PORT' -w sop_$(date +%Y-%m-%d).cap`
3. Connect with a SOP client and send one or more messages from a file: `cat $SOP/test/1k_orders.txt | $SOP/test/sopClient.sh IP PORT`
