#!/bin/bash

export GREEN='\033[0;32m'
export UYELLOW='\033[4;33m'
export WHITE='\033[0;37m' 

if [ "$BOX86_BASH" ] && [ "$BOX64_BASH" ]; then
    echo -e "${GREEN}Looks like the bash86_64 is already insalled."
	read -n 1 -s -r -p "Press any key to continue."
	echo -e "${WHITE}"
	exit
fi

echo -e "${GREEN}Due to lack of binfmt on some devices, the Box86 and Box64 can't run binaries as it is designed."
echo -e "${GREEN}This will setup bash Box environment according to:"
echo -e "${GREEN}https://box86.org/2022/09/running-bash-with-box86-box64/${WHITE}"
echo -e "${GREEN}It is necessary, e.g., to run Steam inside Termux Proot.${WHITE}"
read -n 1 -s -r -p "Press any key to continue."
echo -e "${WHITE}"

echo -e "${GREEN}Download and copy native bash x86 and x64 from the Box git.${WHITE}"
mkdir ~/box_bash
cd ~/box_bash
wget https://github.com/ptitSeb/box86/raw/master/tests/bash -O bash_I386
wget https://github.com/ptitSeb/box64/raw/main/tests/bash -O bash_AMD64
chmod +x bash_I386
chmod +x bash_AMD64
cp bash_I386 /usr/local/bin/
cp bash_AMD64 /usr/local/bin/
cd ~/
rm -r box_bash

echo -e "${GREEN}Set BOX86_BASH and BOX64_BASH to .bashrc.${WHITE}"
echo "export BOX86_BASH=/usr/local/bin/bash_I386
export BOX64_BASH=/usr/local/bin/bash_AMD64" >> ~/.bashrc
source ~/.bashrc

echo -e "${GREEN}Create bash86 and bash64 scripts.${WHITE}"
echo '#!/bin/bash 
box86 '"/usr/local/bin/bash_I386 "'"$@"' > /usr/local/bin/bash86
chmod +x /usr/local/bin/bash86
echo '#!/bin/bash 
box64 '"/usr/local/bin/bash_AMD64 "'"$@"' > /usr/local/bin/bash64
chmod +x /usr/local/bin/bash64

echo -e "${UYELLOW}Now you can run bash with bash86 and bash64 commands.\nBox86 and Box64 will handle automatically most of the scripts using the installed bash, so you don't have to run the scripts with the commands above, just use box86 or box64 like before.${WHITE}"
read -n 1 -s -r -p "Press any key to continue."
echo -e "${WHITE}"