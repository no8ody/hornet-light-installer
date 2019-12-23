#!/bin/bash

############################################################################################################################################################
# CONFIG FOR HORNET INSTALLER
############################################################################################################################################################


os=ARM      # ARM = Raspberry PI3+/4 | x86_64 = VPS
user=iota   # You can specify a own username for the hornet node



############################################################################################################################################################
# DO NOT EDIT THE LINES BELOW !!!
############################################################################################################################################################

source config/config.sh
sudo apt install nano curl jq -y > /dev/null
version="$(curl -s https://api.github.com/repos/gohornet/hornet/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')"
version="${version:1}"

TEXT_RESET='\e[0m'
TEXT_YELLOW='\e[0;33m'
TEXT_RED_B='\e[1;31m'

echo -e $TEXT_YELLOW && echo "Starting installation of hornet" && echo -e $TEXT_RESET
sudo useradd -m $user
sudo mkdir /home/$user > /dev/null && sudo chown $user:$user /home/$user
sudo usermod -d /home/$user -m $user > /dev/null
sudo -u $user mkdir /home/$user/hornet > /dev/null

echo -e $TEXT_YELLOW && echo "Downloading hornet files..." && echo -e $TEXT_RESET
sudo wget -O /tmp/HORNET-"$version"_Linux_"$os".tar.gz https://github.com/gohornet/hornet/releases/download/v$version/HORNET-"$version"_Linux_"$os".tar.gz > /dev/null
sudo tar -xzf /tmp/HORNET-"$version"_Linux_"$os".tar.gz -C /tmp  > /dev/null
sudo mv /tmp/HORNET-"$version"_Linux_"$os"/* /home/$user/hornet/  > /dev/null
sudo rm -r /tmp/HORNET-"$version"_Linux_"$os"*  > /dev/null
sudo wget -O /home/$user/hornet/latest-export.gz.bin https://dbfiles.iota.org/mainnet/hornet/latest-export.gz.bin  > /dev/null
sudo wget -O /home/$user/hornet/config.json https://raw.githubusercontent.com/TangleBay/hornet_light_installer/master/config.json > /dev/null
sudo -u $user mkdir /home/$user/hornet/mainnetdb  > /dev/null
sudo chown -R $user:$user /home/$user/hornet  > /dev/null
sudo chmod 770 /home/$user/hornet/hornet  > /dev/null

echo -e $TEXT_YELLOW && echo "Creating service for hornet..." && echo -e $TEXT_RESET
service=/lib/systemd/system/hornet.service
sudo echo "[Unit]" > $service
sudo echo "Description=HORNET Fullnode" >> $service
sudo echo "After=network.target" >> $service
sudo echo "" >> $service
sudo echo "[Service]" >> $service
sudo echo "WorkingDirectory=/home/$user/hornet" >> $service
sudo echo "User=$user" >> $service
sudo echo "TasksMax=infinity" >> $service
sudo echo "KillSignal=SIGTERM" >> $service
sudo echo "TimeoutStopSec=infinity" >> $service
sudo echo "ExecStart=/home/$user/hornet/hornet -c config" >> $service
sudo echo "SyslogIdentifier=HORNET" >> $service
sudo echo "Restart=on-failure" >> $service
sudo echo "RestartSec=1200" >> $service
sudo echo "" >> $service
sudo echo "[Install]" >> $service
sudo echo "WantedBy=multi-user.target" >> $service
sudo echo "Alias=hornet.service" >> $service

echo -e $TEXT_YELLOW && echo "Activate hornet service..." && echo -e $TEXT_RESET
sudo systemctl daemon-reload
sudo systemctl enable hornet.service
echo -e $TEXT_YELLOW && echo "Starting hornet node! (please note this can may take a while)" && echo -e $TEXT_RESET
sudo systemctl start hornet
echo -e $TEXT_YELLOW && echo "Loading live log and finish installation...(can be skipped with 'strg + c'" && echo -e $TEXT_RESET
sudo journalctl -fu hornet
echo -e $TEXT_RED_B && echo "Finish up hornet installation..." && echo -e $TEXT_RESET
exit 0