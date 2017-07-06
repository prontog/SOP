WSDH_SCRIPT_PATH = os.getenv('WSDH_SCRIPT_PATH') or persconffile_path("")
SOP_SPECS_PATH = os.getenv('SOP_SPECS_PATH') or persconffile_path("") .. "sop"
SOP = os.getenv('SOP') or "/vagrant/sop"
dofile(SOP .. '/network/sop.lua')