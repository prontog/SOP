WSDH_SCRIPT_PATH = os.getenv("WSDH_SCRIPT_PATH") or persconffile_path("")
SOP_SPECS_PATH = os.getenv("SOP_SPECS_PATH") or persconffile_path("") .. "sop"
if os.getenv('SOP') then
	SOP = os.getenv('SOP') .. '/network'
else
	SOP = persconffile_path('') .. 'sop'
end
dofile(SOP .. '/sop.lua')