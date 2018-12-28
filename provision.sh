#!/usr/bin/env bash
set -o errexit
set -x

# Install ZIP
sudo apt-get install zip -y

# Install csvkit
sudo apt-get install -y python-pip
sudo pip install --upgrade pip
sudo pip install --upgrade setuptools
sudo pip install csvkit==0.9.2

# Install TCL
sudo apt-get install tcl -y
