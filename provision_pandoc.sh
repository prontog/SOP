#!/usr/bin/env bash
set -o errexit
set -x

# Install python
sudo apt-get install python -y

# Install Pandoc
curl -LR -O -s https://github.com/jgm/pandoc/releases/download/2.5/pandoc-2.5-1-amd64.deb
sudo dpkg --install pandoc-2.5-1-amd64.deb
git clone https://github.com/jgm/pandocfilters
cd pandocfilters
sudo python setup.py install
cd
