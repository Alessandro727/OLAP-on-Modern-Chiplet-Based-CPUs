#!/bin/bash

sudo apt update

sudo apt install -y wget file software-properties-common numactl bc openssh-server inetutils-ping python net-tools

# Install Python3.6

sudo add-apt-repository -y ppa:jblgf0/python
sudo apt update
sudo apt-get install -y python3.6


# Install Mysql Server

sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password \"''\""
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password \"''\""

sudo apt install -y percona-server-server-5.6 



# Install python libraries

sudo apt install python3 python3-pip

pip3 install numpy==1.19.4

sudo apt install libfreetype6-dev pkg-config libpng12-dev libpython3.6-dev

sudo apt-get install gfortran libopenblas-dev liblapack-dev

sudo python3 -m pip install cppy==1.2.0

sudo python3 -m pip install kiwisolver==1.3.2

sudo python3 -m pip install matplotlib==3.1

sudo python3 -m pip install pybind11==2.4.3

sudo python3 -m pip install scipy==1.5.4 

sudo python3 -m pip install cython

sudo python3 -m pip install pandas

sudo apt install texlive-latex-base

sudo apt-get install dvipng texlive-latex-extra texlive-fonts-recommended 

