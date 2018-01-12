sop_types := NO OC TR RJ EN BO LO
sop_mdtables := $(foreach t, $(sop_types), $(t).mdtable)
sop_specs := $(foreach t, $(sop_types), $(t).csv)
sop_md := sop.md

dissectors := $(shell find -name '*.lua')

sop: $(sop_specs) sop.xml sop_dissector.zip
	touch $@

sop.xml: $(sop_specs)
	./csv2xmlcopybook.sh -F sopsrv_log.csv -p "SOP log" $? > $@

sop_dissector.zip: $(sop_specs) $(dissectors)
	@echo Packing dissector into dissector.zip...
	zip sop_dissector.zip *.csv
	zip -j sop_dissector.zip $(SOP)/network/*.lua $(WSDH_SCRIPT_PATH)/*.lua

%.csv: %.mdtable
	./mdtable_to_csv.sh $?

$(sop_mdtables): $(sop_md)
	# Extract the md tables for each message type.
	./sop_split_to_mdtable.sh $?

.INTERMEDIATE: $(sop_mdtables)

%.md: %.docx
	# Convert documentation from docx format to md.
	pandoc --smart --filter ./despan.py --to markdown_github $? | iconv -f utf8 -t ascii//TRANSLIT > $@

# Clean up rules.
clean: clean_record_editor clean_csv clean_mdtable clean_md
	-rm sop
	-rm sop_dissector.zip

clean_record_editor:
	-rm sop.xml

clean_csv:
	-rm $(sop_specs)

clean_mdtable:
	-rm $(sop_mdtables)

clean_md:
	-rm $(sop_md)
