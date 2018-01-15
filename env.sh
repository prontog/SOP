#!/usr/bin/env bash
# Prepares SOP environment. This file is meant to be sourced.

# Add necessary env vars.
export SOP=${SOP-${BASH_SOURCE%/*}}
export WSDH_SCRIPT_PATH=${WSDH_SCRIPT_PATH-~/ws_dissector_helper/src/}
export SOP_SPECS_PATH=${SOP_SPECS_PATH-$SOP/specs/}
# Update PATH with all dirs containing scripts.
PATH=${PATH}:$SOP/network:$SOP/stats
