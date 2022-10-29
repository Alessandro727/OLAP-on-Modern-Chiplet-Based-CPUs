#!/bin/bash

#Add GPG key
wget -O - 'https://release.memsql.com/release-aug2018.gpg'  2>/dev/null | sudo apt-key add - && apt-key list

#Install apt-transport-https
sudo apt -y install apt-transport-https

#Add the SingleStore repository
echo "deb [arch=amd64] https://release.memsql.com/production/debian memsql main" | sudo tee /etc/apt/sources.list.d/memsql.list

#Install SingleStore
sudo apt update && sudo apt -y install singlestoredb-toolbox singlestore-client singlestoredb-studio

#Enable sudo
#sudo echo "user = \"root\"" >> /root/.config/singlestoredb-toolbox/toolbox.hcl
