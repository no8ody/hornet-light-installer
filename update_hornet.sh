#!/bin/bash

############################################################################################################################################################
# DO NOT EDIT THE LINES BELOW !!!
############################################################################################################################################################
source install_hornet.sh
TEXT_RESET='\e[0m'
TEXT_YELLOW='\e[0;33m'
TEXT_RED_B='\e[1;31m'
echo -e $TEXT_YELLOW && echo "Get latest hornet version..." && echo -e $TEXT_RESET
version="$(curl -s https://api.github.com/repos/gohornet/hornet/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')"
version="${version:1}"
echo -e $TEXT_RED_B && echo "Latest Version: $version" && echo -e $TEXT_RESET
echo -e $TEXT_YELLOW && echo "Stopping hornet node...(Please note that this may take some time)" && echo -e $TEXT_RESET
sudo systemctl stop hornet
echo -e $TEXT_YELLOW && echo "Downloading new hornet file..." && echo -e $TEXT_RESET
sudo wget -O /tmp/HORNET-"$version"_Linux_"$os".tar.gz https://github.com/gohornet/hornet/releases/download/v$version/HORNET-"$version"_Linux_"$os".tar.gz > /dev/null
sudo tar -xzf /tmp/HORNET-"$version"_Linux_"$os".tar.gz -C /tmp  > /dev/null
sudo mv /tmp/HORNET-"$version"_Linux_"$os"/hornet /home/$user/hornet/  > /dev/null
sudo rm -r /tmp/HORNET-"$version"_Linux_"$os"*  > /dev/null
sudo chown $user:$user /home/$user/hornet/hornet  > /dev/null
sudo chmod 770 /home/$user/hornet/hornet  > /dev/null
echo -e $TEXT_YELLOW && echo "Starting hornet node...(Please note that this may take some time)" && echo -e $TEXT_RESET
sudo systemctl start hornet
echo -e $TEXT_RED_B && echo "Update finished...Bye!" && echo -e $TEXT_RESET
exit 0