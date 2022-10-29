#!/bin/bash

# Add the Greenplum PPA repository
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:greenplum/db
sudo apt update

# Install Greenplum Database
sudo apt install -y greenplum-db-5

# Source greenplum_path.sh
source /opt/gpdb/greenplum_path.sh

sudo locale-gen en_US.UTF-8

#Install numactl
sudo apt install -y numactl
