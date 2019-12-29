#!/bin/bash

############################################################################################################################################################
############################################################################################################################################################
# DO NOT EDIT THE LINES BELOW !!! DO NOT EDIT THE LINES BELOW !!! DO NOT EDIT THE LINES BELOW !!! DO NOT EDIT THE LINES BELOW !!!
############################################################################################################################################################
############################################################################################################################################################
currenthli=0.0.5

TEXT_RESET='\e[0m'
TEXT_YELLOW='\e[0;33m'
TEXT_RED_B='\e[1;31m'
clear

if ! [ -x "$(command -v curl)" ]; then
    echo -e $TEXT_YELLOW && echo "Installing necessary packages curl..." && echo -e $TEXT_RESET
    sudo apt install curl -y > /dev/null
    clear
fi
if ! [ -x "$(command -v jq)" ]; then
    echo -e $TEXT_YELLOW && echo "Installing necessary package jq..." && echo -e $TEXT_RESET
    sudo apt install jq -y > /dev/null
    clear
fi

echo -e $TEXT_YELLOW && echo "Welcome to the Hornet lightweight installer!" && echo -e $TEXT_RESET
latesthli="$(curl -s https://api.github.com/repos/TangleBay/hornet-light-installer/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')"

if [ "$currenthli" != "$latesthli" ]; then
    echo -e $TEXT_RED_B && echo "New version available! Downloading new version..." && echo -e $TEXT_RESET
    sudo wget -q -O hornet-installer.sh https://raw.githubusercontent.com/TangleBay/hornet-light-installer/master/hornet-installer.sh
    sudo chmod +x hornet-installer.sh
    echo -e $TEXT_YELLOW && read -p "Do you want to reset installer config (y/N): " resetconf
    echo -e $TEXT_RESET
    if [ "$resetconf" = "y" ] || [ "$resetconf" = "Y" ]; then
        echo -e $TEXT_YELLOW && echo "Creating backup of the config file..." && echo -e $TEXT_RESET
        sudo mv config.sh config.sh.bak
        echo -e $TEXT_YELLOW && echo "Downloading latest installer configuration..." && echo -e $TEXT_RESET
        sudo wget -q -O config.sh https://raw.githubusercontent.com/TangleBay/hornet-light-installer/master/configs/config.sh
        sudo nano config.sh
    fi
    echo -e $TEXT_RED_B && echo "Please re-run the installer!" && echo -e $TEXT_RESET
    exit 0
fi

if [ ! -f "config.sh" ]; then
    echo -e $TEXT_YELLOW && echo "First run detected...Downloading config file!" && echo -e $TEXT_RESET
    sudo wget -q -O config.sh https://raw.githubusercontent.com/TangleBay/hornet-light-installer/master/configs/config.sh
    sudo nano config.sh
    echo -e $TEXT_RED_B && echo "Please re-run the hornet-installer!" && echo -e $TEXT_RESET
    exit 0
fi
source config.sh
nodev="$(curl -s http://127.0.0.1:14265 -X POST -H 'Content-Type: application/json' -H 'X-IOTA-API-Version: 1' -d '{"command": "getNodeInfo"}' | jq '.appVersion')"
latesthornet="$(curl -s https://api.github.com/repos/gohornet/hornet/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')"
latesthornet="${latesthornet:1}"

echo -e $TEXT_RED_B
echo Current Hornet: $nodev
echo Latest Hornet: \"$latesthornet\"
echo -e $TEXT_RESET

echo -e $TEXT_YELLOW
echo "Installer Management"
echo ""
echo "a) Install the hornet node"
echo "b) Install the reverse proxy"
echo "c) Add your node to Tangle Bay"
echo "d) Remove your node from Tangle Bay"
echo ""
echo ""
echo "Node Management"
echo ""
echo "1) Restart/Stop hornet"
echo "2) Show live log"
echo "3) Update the hornet node"
echo "4) Reset node database"
echo "5) Reset/Reload Hornet config"
echo ""
echo "e) Exit"
echo -e $TEXT_RESET
echo -e $TEXT_YELLOW && read -p "Please type in your option: " selector
echo -e $TEXT_RESET

if [ "$selector" = "a" ] || [ "$selector" = "A" ]; then
    echo -e $TEXT_YELLOW && echo "Installing necessary packages..." && echo -e $TEXT_RESET
    sudo apt install nano -y

    echo -e $TEXT_YELLOW && echo "Starting installation of hornet" && echo -e $TEXT_RESET
    sudo useradd -m $user
    sudo mkdir /home/$user > /dev/null && sudo chown $user:$user /home/$user
    sudo usermod -d /home/$user -m $user
    sudo -u $user mkdir /home/$user/hornet

    echo -e $TEXT_YELLOW && echo "Downloading hornet files..." && echo -e $TEXT_RESET
    sudo wget -O /tmp/HORNET-"$latesthornet"_Linux_"$os".tar.gz https://github.com/gohornet/hornet/releases/download/v$latesthornet/HORNET-"$latesthornet"_Linux_"$os".tar.gz
    sudo tar -xzf /tmp/HORNET-"$latesthornet"_Linux_"$os".tar.gz -C /tmp
    sudo mv /tmp/HORNET-"$latesthornet"_Linux_"$os"/* /home/$user/hornet/
    sudo rm -r /tmp/HORNET-"$latesthornet"_Linux_"$os"*
    sudo wget -O /home/$user/hornet/latest-export.gz.bin https://dbfiles.iota.org/mainnet/hornet/latest-export.gz.bin
    sudo wget -q -O /home/$user/hornet/config.json https://raw.githubusercontent.com/TangleBay/hornet-light-installer/master/configs/hornet.conf
    sudo find /home/$user/hornet/config.json -type f -exec sed -i 's/"auto"/'\"$profile\"'/g' {} \;
    sudo find /home/$user/hornet/config.json -type f -exec sed -i 's/3NnxP8ajMp/'$dashuser'/g' {} \;
    sudo find /home/$user/hornet/config.json -type f -exec sed -i 's/AiU9N49WBL/'$dashpw'/g' {} \;
    sudo find /home/$user/hornet/config.json -type f -exec sed -i 's/neighbor1:15600/'$neighbor1'/g' {} \;
    sudo find /home/$user/hornet/config.json -type f -exec sed -i 's/neighbor2:15600/'$neighbor2'/g' {} \;
    sudo find /home/$user/hornet/config.json -type f -exec sed -i 's/neighbor3:15600/'$neighbor3'/g' {} \;
    sudo find /home/$user/hornet/config.json -type f -exec sed -i 's/neighbor4:15600/'$neighbor4'/g' {} \;
    sudo find /home/$user/hornet/config.json -type f -exec sed -i 's/neighbor5:15600/'$neighbor5'/g' {} \;
    sudo -u $user mkdir /home/$user/hornet/mainnetdb
    sudo chown -R $user:$user /home/$user/hornet
    sudo chmod 770 /home/$user/hornet/hornet

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
    echo -e $TEXT_YELLOW && echo "Starting hornet node! (Please note that this may take some time)" && echo -e $TEXT_RESET
    sudo systemctl restart hornet
    sudo systemctl status hornet

    echo -e $TEXT_RED_B && echo "Hornet installation finished, bye!" && echo -e $TEXT_RESET
    exit 0
fi

if [ "$selector" = "b" ] || [ "$selector" = "B" ]; then
    echo -e $TEXT_YELLOW && echo "Installing necessary packages..." && echo -e $TEXT_RESET
    sudo apt install software-properties-common curl jq -y
    sudo add-apt-repository ppa:certbot/certbot -y
    sudo apt update && sudo apt install python-certbot-nginx -y
    sudo apt update && sudo apt dist-upgrade -y && sudo apt upgrade -y && apt autoremove -y

    echo -e $TEXT_YELLOW && echo "Updating Nginx..." && echo -e $TEXT_RESET
    sudo mkdir /etc/systemd/system/nginx.service.d &&
    sudo printf "[Service]\nExecStartPost=/bin/sleep 0.1\n" > /etc/systemd/system/nginx.service.d/override.conf &&
    sudo systemctl daemon-reload

    echo -e $TEXT_YELLOW && echo "Downloading Nginx configuration..." && echo -e $TEXT_RESET
    sudo wget -q -O /etc/nginx/sites-available/default https://raw.githubusercontent.com/TangleBay/hornet-light-installer/master/configs/nginx.conf
    sudo find /etc/nginx/sites-available/default -type f -exec sed -i 's/domain.tld/'$domain'/g' {} \;
    sudo find /etc/nginx/sites-available/default -type f -exec sed -i 's/14266/'$trinityport'/g' {} \;
    sudo find /etc/nginx/sites-available/default -type f -exec sed -i 's/14267/'$dashport'/g' {} \;
    sudo find /etc/nginx/nginx.conf -type f -exec sed -i 's/\# server_names_hash_bucket_size 64;/server_names_hash_bucket_size 64;/g' {} \;
    sudo systemctl restart nginx

    echo -e $TEXT_YELLOW && echo "Starting SSL-Certificate installation..." && echo -e $TEXT_RESET
    sudo certbot --nginx -d $domain

    if [ -f "/etc/letsencrypt/live/$domain/fullchain.pem" ]; then
        sudo find /etc/nginx/sites-available/default -type f -exec sed -i 's/\#RjtV27dw/''/g' {} \;
        sudo systemctl restart nginx
    fi
    echo -e $TEXT_RED_B && echo "Reverse proxy installation finished, bye!" && echo -e $TEXT_RESET
    exit 0
fi

if [ "$selector" = "c" ] || [ "$selector" = "C" ]; then
    domain2=https://$domain:$trinityport
    curl -X POST "https://community.tanglebay.org/nodes" -H  "accept: */*" -H  "Content-Type: application/json" -d "{ \"name\": \"$name\", \"url\": \"$domain2\", \"pow\": \"$pow\" }" |jq
    exit 0
fi

if [ "$selector" = "d" ] || [ "$selector" = "D" ]; then
	curl -X DELETE https://community.tanglebay.org/nodes/$password |jq
    exit 0
fi

if [ "$selector" = "1" ] ; then
    echo -e $TEXT_YELLOW && read -p "What would you like to (r)estart or (s)top the node: " startstop
    echo -e $TEXT_RESET
    if [ "$selector" = "r" ] || [ "$selector" = "R" ]; then
        sudo systemctl restart hornet
    fi
    if [ "$selector" = "s" ] || [ "$selector" = "S" ]; then
        sudo systemctl stop hornet
    fi
    exit 0
fi

if [ "$selector" = "2" ] ; then
    sudo journalctl -fu hornet
    exit 0
fi

if [ "$selector" = "3" ] ; then
	echo -e $TEXT_YELLOW && echo "Get latest hornet version..." && echo -e $TEXT_RESET
	echo -e $TEXT_YELLOW && echo "Stopping hornet node...(Please note that this may take some time)" && echo -e $TEXT_RESET
	sudo systemctl stop hornet
	echo -e $TEXT_YELLOW && echo "Downloading new hornet file..." && echo -e $TEXT_RESET
	sudo wget -O /tmp/HORNET-"$latesthornet"_Linux_"$os".tar.gz https://github.com/gohornet/hornet/releases/download/v$latesthornet/HORNET-"$latesthornet"_Linux_"$os".tar.gz
	sudo tar -xzf /tmp/HORNET-"$latesthornet"_Linux_"$os".tar.gz -C /tmp
	sudo mv /tmp/HORNET-"$latesthornet"_Linux_"$os"/hornet /home/$user/hornet/
	sudo rm -r /tmp/HORNET-"$latesthornet"_Linux_"$os"*
	sudo chown $user:$user /home/$user/hornet/hornet
	sudo chmod 770 /home/$user/hornet/hornet
	echo -e $TEXT_YELLOW && echo "Starting hornet node...(Please note that this may take some time)" && echo -e $TEXT_RESET
	sudo systemctl start hornet
	echo -e $TEXT_RED_B && echo "Hornet update finished, bye!" && echo -e $TEXT_RESET
	exit 0
fi

if [ "$selector" = "4" ]; then
    sudo systemctl stop hornet
    sudo rm -r /home/$user/hornet/mainnetdb/*
    echo -e $TEXT_YELLOW && read -p "Would you like to download the latest snapshot (y/N): " snapdb
    echo -e $TEXT_RESET
    if [ "$snapdb" = "y" ] || [ "$snapdb" = "Y" ]; then
        echo -e $TEXT_YELLOW && echo "Downloading snapshot file..." && echo -e $TEXT_RESET
        sudo rm /home/$user/hornet/latest-export.gz.bin
        sudo -u $user wget -O /home/$user/hornet/latest-export.gz.bin https://dbfiles.iota.org/mainnet/hornet/latest-export.gz.bin
    fi
    sudo systemctl restart hornet
    echo -e $TEXT_RED_B && echo "Reset of the database finished, bye!" && echo -e $TEXT_RESET
    exit 0
fi

if [ "$selector" = "5" ]; then
    echo -e $TEXT_YELLOW && echo "Resetting current hornet configuration..." && echo -e $TEXT_RESET
    sudo -u $user wget -q -O /home/$user/hornet/config.json https://raw.githubusercontent.com/TangleBay/hornet-light-installer/master/configs/hornet.conf
    echo -e $TEXT_YELLOW && echo "Setting configuration parameters..." && echo -e $TEXT_RESET
    sudo find /home/$user/hornet/config.json -type f -exec sed -i 's/"auto"/'\"$profile\"'/g' {} \;
    sudo find /home/$user/hornet/config.json -type f -exec sed -i 's/neighbor1.domain.tld:15600/'$neighbor1'/g' {} \;
    sudo find /home/$user/hornet/config.json -type f -exec sed -i 's/neighbor2.domain.tld:15600/'$neighbor2'/g' {} \;
    sudo find /home/$user/hornet/config.json -type f -exec sed -i 's/neighbor3.domain.tld:15600/'$neighbor3'/g' {} \;
    sudo find /home/$user/hornet/config.json -type f -exec sed -i 's/neighbor4.domain.tld:15600/'$neighbor4'/g' {} \;
    sudo find /home/$user/hornet/config.json -type f -exec sed -i 's/neighbor5.domain.tld:15600/'$neighbor5'/g' {} \;
    echo -e $TEXT_YELLOW && echo "Restarting hornet node with new configuration..." && echo -e $TEXT_RESET
    sudo systemctl restart hornet
    echo -e $TEXT_RED_B && echo "Configuration reset finished, bye!" && echo -e $TEXT_RESET
    exit 0
fi

if [ "$selector" = "e" ] || [ "$selector" = "E" ]; then
    exit 0
fi
exit 0