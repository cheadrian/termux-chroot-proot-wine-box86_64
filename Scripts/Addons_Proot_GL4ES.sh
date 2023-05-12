#!/bin/bash

export GREEN='\033[0;32m'
export UYELLOW='\033[4;33m'
export WHITE='\033[0;37m' 

echo -e "${GREEN}This will compile and install GL4ES inside the proot."
read -n 1 -s -r -p "Press any key to continue."
echo -e "${WHITE}"

echo -e "${GREEN}Install necessary packages.${WHITE}"
apt install -y git gcc build-essential cmake libx11-dev

echo -e "${GREEN}Clone the repo.${WHITE}"
cd ~
git clone https://github.com/ptitSeb/gl4es
cd gl4es

echo -e "${GREEN}Build and install GL4ES.${WHITE}"
mkdir build; cd build; cmake -S ../../gl4es; make install

echo -e "${GREEN}Clean.${WHITE}"
cd ~
rm -r gl4es

echo -e "${UYELLOW}Now you can use gl4es like this, e.g.:\nLD_LIBRARY_PATH="/usr/lib/gl4es/" glmark2.${WHITE}"
read -n 1 -s -r -p "Press any key to continue."
echo -e "${WHITE}"