#!/bin/bash

############################################################################################################################################################
############################################################################################################################################################
# DO NOT EDIT THE LINES BELOW !!!
############################################################################################################################################################
############################################################################################################################################################
source config/config.sh
version="$(curl -s https://api.github.com/repos/gohornet/hornet/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')"
version="${version:1}"

TEXT_RESET='\e[0m'
TEXT_YELLOW='\e[0;33m'
TEXT_RED_B='\e[1;31m'

echo -e $TEXT_YELLOW && echo "Starting installation of hornet" && echo -e $TEXT_RESET
sudo apt install wget tar nano curl jq -y > /dev/null
sudo useradd -m $user
sudo -u $user mkdir /home/$user/hornet

echo -e $TEXT_YELLOW && echo "Downloading hornet files..." && echo -e $TEXT_RESET
sudo wget -O /tmp/HORNET-"$version"_Linux_"$os".tar.gz https://github.com/gohornet/hornet/releases/download/v$version/HORNET-"$version"_Linux_"$os".tar.gz > /dev/null
sudo tar -xzf /tmp/HORNET-"$version"_Linux_"$os".tar.gz -C /tmp  > /dev/null
sudo mv /tmp/HORNET-"$version"_Linux_"$os"/* /home/$user/hornet/  > /dev/null
sudo rm -r /tmp/HORNET-"$version"_Linux_"$os"*  > /dev/null
sudo wget -O /home/$user/hornet/latest-export.gz.bin https://dbfiles.iota.org/mainnet/hornet/latest-export.gz.bin  > /dev/null
sudo cp ./config/hornet.conf /home/$user/hornet/config.json
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
echo -e $TEXT_YELLOW && echo "Loading live log and finish installation..." && echo -e $TEXT_RESET
sudo journalctl -fu hornet
echo -e $TEXT_RED_B && echo "Finish up hornet installation..." && echo -e $TEXT_RESET

proxy=n
read -p "You want set up a reverse proxy? (y/N): " proxy
if [ $proxy == y ]
    echo -e $TEXT_YELLOW && echo "Setting up reverse proxy..." && echo -e $TEXT_RESET
    sudo add-apt-repository ppa:certbot/certbot
    sudo apt install python-certbot-nginx -You
    sudo apt update > /dev/null && sudo apt dist-upgrade -y > /dev/null && sudo apt upgrade -y > /dev/null && sudo apt autoremove -y > /dev/null
    sudo cat config/nginx.conf > /etc/nginx/site-available/default
    sudo systemctl restart nginx
    sudo certbot --nginx -d $domain
    echo -e $TEXT_YELLOW && echo "Finish reverse proxy setup..." && echo -e $TEXT_RESET
fi


read -p "You want to add your node to Tangle Bay? (y/N): " tbadd
tbadd=n
if [ $tbadd == y ]
    echo -e $TEXT_YELLOW && echo "Adding node to Tangle Bay..." && echo -e $TEXT_RESET
    curl https://community.tanglebay.org/nodes -X POST -H 'Content-type: application/json' -d '{"name": $name, "url": "https://$domain:$port", "pow": $pow}' |jq
fi
exit 0