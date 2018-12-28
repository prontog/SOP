#!/usr/bin/env bash
set -o errexit
set -x

# Install R
sudo apt-get install -y libssl-dev libcurl4-openssl-dev
sudo apt-get install -y r-base r-base-dev
sudo Rscript /vagrant/stats/prepare_r_env.R
#cd /vagrant/stats
#sudo R CMD INSTALL . athex
# RStudio Server
RSTUDIO_VERSION=1.1.463
sudo apt-get install -y gdebi-core
curl -R -O -s https://download2.rstudio.org/rstudio-server-${RSTUDIO_VERSION}-amd64.deb
sudo dpkg --install rstudio-server-${RSTUDIO_VERSION}-amd64.deb
sudo systemctl enable rstudio-server.service
# To login to rstudio-server you need to create a user and add the user to
# rstudio-server group. Make sure the user has a home dir too!
