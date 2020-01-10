#!/bin/bash

############################################################################################################################################################
############################################################################################################################################################
# DO NOT EDIT THE LINES BELOW !!! DO NOT EDIT THE LINES BELOW !!! DO NOT EDIT THE LINES BELOW !!! DO NOT EDIT THE LINES BELOW !!!
############################################################################################################################################################
############################################################################################################################################################
version=0.1.4

TEXT_RESET='\e[0m'
TEXT_YELLOW='\e[0;33m'
TEXT_RED_B='\e[1;31m'
clear

function pause(){
   read -p "$*"
}

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

############################################################################################################################################################

snapshot=https://dbfiles.iota.org/mainnet/hornet/latest-export.gz.bin
latesthornet="$(curl -s https://api.github.com/repos/gohornet/hornet/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')"
latesthornet="${latesthornet:1}"
latesthli="$(curl -s https://api.github.com/repos/TangleBay/hornet-light-installer/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')"

getnbconf='sudo -u $user wget -q -O /home/$user/hornet/neighbors.json https://raw.githubusercontent.com/gohornet/hornet/develop/neighbors.json'

setnbs='sudo sed -i 's/\"example1.neighbor.com:15600\"/\"'$neighbor1'\"/g' /home/$user/hornet/neighbors.json && sudo sed -i 's/\"example2.neighbor.com:15600\"/\"'$neighbor2'\"/g' /home/$user/hornet/neighbors.json && sudo sed -i 's/\"example3.neighbor.com:15600\"/\"'$neighbor3'\"/g' /home/$user/hornet/neighbors.json'

setprofile='sudo sed -i 's/\"useProfile\": \"auto\"/\"useProfile\": \"'$profile'\"/g' /home/$user/hornet/config.json'
setdashauth='sudo sed -i 's/\"enabled\": false/\"enabled\": '$dashauth'/g' /home/$user/hornet/config.json'
setdashuser='sudo sed -i 's/\"username\": "hornet"/\"username\": \"'$dashuser'\"/g' /home/$user/hornet/config.json'
setdashpw='sudo sed -i 's/\"password\": "hornet"/\"password\": \"'$dashpw'\"/g' /home/$user/hornet/config.json'
setnbport='sudo sed -i 's/\"Port\": 15600/\"Port\": $nbport/g' /home/$user/hornet/config.json'

setdomain='sudo find /etc/nginx/sites-available/default -type f -exec sed -i 's/domain.tld/'$domain'/g' {} \;'
settrinityport='sudo find /etc/nginx/sites-available/default -type f -exec sed -i 's/14266/'$trinityport'/g' {} \;'
setdashport='sudo find /etc/nginx/sites-available/default -type f -exec sed -i 's/14267/'$dashport'/g' {} \;'
sethashsize='sudo find /etc/nginx/nginx.conf -type f -exec sed -i 's/\# server_names_hash_bucket_size 64;/server_names_hash_bucket_size 64;/g' {} \;'

############################################################################################################################################################

if [ "$version" != "$latesthli" ]; then
    echo -e $TEXT_RED_B && echo "New version available (v$latesthli)! Downloading new version..." && echo -e $TEXT_RESET
    sudo wget -q -O hornet-installer.sh https://raw.githubusercontent.com/TangleBay/hornet-light-installer/master/hornet-installer.sh
    sudo chmod +x hornet-installer.sh
    sleep 2
    ScriptLoc=$(readlink -f "$0")
    exec "$ScriptLoc"
    exit 0
fi

if [ ! -f "config.sh" ]; then
    echo -e $TEXT_YELLOW && echo "First run detected...Downloading config file!" && echo -e $TEXT_RESET
    sudo wget -q -O config.sh https://raw.githubusercontent.com/TangleBay/hornet-light-installer/master/configs/config.sh
    sudo nano config.sh
fi

counter=0
while [ $counter -lt 1 ]; do
    clear
    source config.sh
    nodev="$(curl -s http://127.0.0.1:14265 -X POST -H 'Content-Type: application/json' -H 'X-IOTA-API-Version: 1' -d '{"command": "getNodeInfo"}' | jq '.appVersion')"


    echo -e $TEXT_YELLOW && echo "Welcome to the (HLI) Hornet lightweight installer! [v$version]" && echo -e $TEXT_RESET
    echo -e $TEXT_RED_B
    echo Current Hornet: $nodev
    echo Latest Hornet: \"$latesthornet\"
    echo -e $TEXT_RESET

    echo -e $TEXT_YELLOW
    echo "1) Hornet Manager"
    echo "2) Tangle Bay Manager"
    echo "3) Hornet Installer"
    echo ""
    echo "x) Exit"
    echo -e $TEXT_RESET
    echo -e $TEXT_YELLOW && read -p "Please type in your option: " selector
    echo -e $TEXT_RESET
    echo -e $TEXT_YELLOW && echo "====================================" && echo -e $TEXT_RESET


    if [ "$selector" = "1" ]; then
    unset selector
    selectcounter=0
        while [ $selectcounter -lt 1 ]; do
            clear
            echo "Node Management"
            echo ""
            echo "1) Control hornet (start/stop)"
            echo "2) Show latest live log"
            echo "3) Edit neighbors.json"
            echo "4) Edit config.json"
            echo "5) Update the hornet node"
            echo "6) Reset node database"
            echo ""
            echo "b) Back"
            echo -e $TEXT_YELLOW && read -p "Please type in your option: " selector
            echo -e $TEXT_RESET
            echo -e $TEXT_YELLOW && echo "====================================" && echo -e $TEXT_RESET
            if [ "$selector" = "1" ] ; then
                echo -e $TEXT_YELLOW && read -p "Would you like to (r)estart/(h)stop/(s)tatus or (c)ancel: " selector1
                echo -e $TEXT_RESET
                if [ "$selector1" = "r" ] || [ "$selector1" = "R" ]; then
                    unset selector1
                    sudo systemctl restart hornet
                    echo -e $TEXT_YELLOW && echo "Hornet node (re)started!" && echo -e $TEXT_RESET
                    echo -e $TEXT_RED_B && pause 'Press [Enter] key to continue...'
                    echo -e $TEXT_RESET
                fi
                if [ "$selector1" = "h" ] || [ "$selector1" = "H" ]; then
                    unset selector1
                    sudo systemctl stop hornet
                    echo -e $TEXT_YELLOW && echo "Hornet node stopped!" && echo -e $TEXT_RESET
                    echo -e $TEXT_RED_B && pause 'Press [Enter] key to continue...'
                    echo -e $TEXT_RESET
                fi
                if [ "$selector1" = "s" ] || [ "$selector1" = "S" ]; then
                    unset selector1
                    sudo systemctl status hornet
                    echo -e $TEXT_RED_B && pause 'Press [Enter] key to continue...'
                    echo -e $TEXT_RESET
                fi
            fi
            if [ "$selector" = "2" ] ; then
                unset selector
                sudo journalctl -fu hornet | less -FRSXM
            fi
            if [ "$selector" = "3" ] ; then
                unset selector
                if [ ! -f "/home/$user/hornet/neighbors.json" ]; then
                    echo -e $TEXT_YELLOW && echo "No neighbors.json found...Downloading config file!" && echo -e $TEXT_RESET

                    # Variables
                    $getnbconf && $setnbs
                fi
                sudo nano /home/$user/hornet/neighbors.json
                echo -e $TEXT_YELLOW && read -p "Would you like to restart hornet now (y/N): " selector3
                if [ "$selector3" = "y" ] || [ "$selector3" = "y" ]; then
                    unset selector3
                    sudo systemctl restart hornet
                    echo -e $TEXT_YELLOW && echo "Hornet node restarted!" && echo -e $TEXT_RESET
                    echo -e $TEXT_RED_B && pause 'Press [Enter] key to continue...'
                    echo -e $TEXT_RESET
                fi
            fi
            if [ "$selector" = "4" ] ; then
                unset selector
                sudo nano /home/$user/hornet/config.json
                echo -e $TEXT_YELLOW && read -p "Would you like to restart hornet now (y/N): " selector4
                if [ "$selector4" = "y" ] || [ "$selector4" = "y" ]; then
                    unset selector4
                    sudo systemctl restart hornet
                    echo -e $TEXT_YELLOW && echo "Hornet node restarted!" && echo -e $TEXT_RESET
                    echo -e $TEXT_RED_B && pause 'Press [Enter] key to continue...'
                    echo -e $TEXT_RESET
                fi
            fi
            if [ "$selector" = "5" ] ; then
                unset selector
                echo -e $TEXT_YELLOW && echo "Get latest hornet version..." && echo -e $TEXT_RESET
                echo -e $TEXT_YELLOW && echo "Stopping hornet node...(Please note that this may take some time)" && echo -e $TEXT_RESET
                sudo systemctl stop hornet
                echo -e $TEXT_YELLOW && echo "Downloading new hornet file..." && echo -e $TEXT_RESET
                sudo wget -O /tmp/HORNET-"$latesthornet"_Linux_"$os".tar.gz https://github.com/gohornet/hornet/releases/download/v$latesthornet/HORNET-"$latesthornet"_Linux_"$os".tar.gz
                sudo tar -xzf /tmp/HORNET-"$latesthornet"_Linux_"$os".tar.gz -C /tmp
                sudo mv /tmp/HORNET-"$latesthornet"_Linux_"$os"/hornet /home/$user/hornet/
                echo -e $TEXT_YELLOW && echo "Backup current config.json..." && echo -e $TEXT_RESET
                sudo -u $user mv /home/$user/hornet/config.json /home/$user/hornet/config.json.bak
                echo -e $TEXT_YELLOW && echo "Resetting current hornet configuration..." && echo -e $TEXT_RESET
                sudo mv /tmp/HORNET-"$latesthornet"_Linux_"$os"/config.json /home/$user/hornet/

                $setprofile && $setdashauth && $setdashuser && $setdashpw && $setnbport

                sudo rm -r /tmp/HORNET-"$latesthornet"_Linux_"$os"*
                sudo chown -R $user:$user /home/$user/hornet
                sudo chmod 770 /home/$user/hornet/hornet
                if [ ! -f "/home/$user/hornet/neighbors.json" ]; then
                    echo -e $TEXT_YELLOW && echo "No neighbors.json found...Downloading config file!" && echo -e $TEXT_RESET
                    # Variables
                    $getnbconf && $setnbs

                    sudo nano /home/$user/hornet/neighbors.json
                fi
            fi
            if [ "$selector" = "6" ]; then
                unset selector
                echo -e $TEXT_RED_B && read -p "Do you really want to reset database (y/N): " selector6
                echo -e $TEXT_RESET
                if [ "$selector6" = "y" ] || [ "$selector6" = "Y" ]; then
                    unset selector6
                    sudo systemctl stop hornet
                    sudo rm -r /home/$user/hornet/mainnetdb/*
                    echo -e $TEXT_YELLOW && read -p "Would you like to download the latest snapshot (y/N): " selector6
                    echo -e $TEXT_RESET
                    if [ "$selector6" = "y" ] || [ "$selector6" = "Y" ]; then
                        unset selector6
                        echo -e $TEXT_YELLOW && echo "Downloading snapshot file..." && echo -e $TEXT_RESET
                        sudo rm /home/$user/hornet/latest-export.gz.bin
                        sudo -u $user wget -O /home/$user/hornet/latest-export.gz.bin $snapshot
                    fi
                    sudo systemctl restart hornet
                    echo -e $TEXT_YELLOW && echo "Reset of the database finished and hornet restarted!" && echo -e $TEXT_RESET
                    echo -e $TEXT_RED_B && pause 'Press [Enter] key to continue...'
                    echo -e $TEXT_RESET
                fi
            fi
            if [ "$selector" = "b" ] || [ "$selector" = "B" ]; then
                unset selector
                let selectcounter=selectcounter+1
            fi
        done
    fi
    if [ "$selector" = "2" ]; then
    unset selector
        selectcounter=0
        while [ $selectcounter -lt 1 ]; do
            clear
            echo "1) Edit HLI config"
            echo "2) Add your node to Tangle Bay"
            echo "3) Remove your node from Tangle Bay"
            echo "4) Update node in Tangle Bay"
            echo ""
            echo "b) Back"
            echo -e $TEXT_YELLOW && read -p "Please type in your option: " selector
            echo -e $TEXT_RESET
            echo -e $TEXT_YELLOW && echo "====================================" && echo -e $TEXT_RESET
            if [ "$selector" = "1" ]; then
                unset selector
                sudo nano config.sh
            fi
            if [ "$selector" = "2" ]; then
                domain2=https://$domain:$trinityport
                curl -X POST "https://api.tanglebay.org/nodes" -H  "accept: */*" -H  "Content-Type: application/json" -d "{ \"name\": \"$name\", \"url\": \"$domain2\", \"address\": \"$address\", \"pow\": \"$pow\" }" |jq
                echo -e $TEXT_RED_B && pause 'Press [Enter] key to continue...'
                echo -e $TEXT_RESET
            fi
            if [ "$selector" = "3" ]; then
                curl -X DELETE https://api.tanglebay.org/nodes/$password |jq
                echo -e $TEXT_RED_B && pause 'Press [Enter] key to continue...'
                echo -e $TEXT_RESET
            fi
            if [ "$selector" = "4" ]; then
                unset selector
                domain2=https://$domain:$trinityport
                curl -X DELETE https://api.tanglebay.org/nodes/$password > /dev/null
                curl -X POST "https://api.tanglebay.org/nodes" -H  "accept: */*" -H  "Content-Type: application/json" -d "{ \"name\": \"$name\", \"url\": \"$domain2\", \"address\": \"$address\", \"password\": \"$password\"\"pow\": \"$pow\" }" |jq
                echo -e $TEXT_RED_B && pause 'Press [Enter] key to continue...'
                echo -e $TEXT_RESET
            fi
            if [ "$selector" = "b" ] || [ "$selector" = "B" ]; then
                unset selector
                let selectcounter=selectcounter+1
            fi
        done
    fi
    if [ "$selector" = "3" ]; then
    unset selector
    selectcounter=0
        while [ $selectcounter -lt 1 ]; do
            clear
            echo "1) Edit HLI config"
            echo "2) Install the hornet node"
            echo "3) Install the reverse proxy"
            echo ""
            echo "b) Back"
            echo -e $TEXT_YELLOW && read -p "Please type in your option: " selector
            echo -e $TEXT_RESET
            echo -e $TEXT_YELLOW && echo "====================================" && echo -e $TEXT_RESET
            if [ "$selector" = "1" ]; then
                unset selector
                sudo nano config.sh
            fi
            if [ "$selector" = "2" ]; then
                unset selector
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
                sudo -u $user wget -O /home/$user/hornet/latest-export.gz.bin $snapshot
                
                # Variables
                $setprofile && $setdashauth && $setdashuser && $setdashpw && $setnbport && $setnbs

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

                echo -e $TEXT_YELLOW && echo "Hornet installation finished!" && echo -e $TEXT_RESET
                echo -e $TEXT_RED_B && pause 'Press [Enter] key to continue...'
                echo -e $TEXT_RESET
            fi
            if [ "$selector" = "3" ]; then
                unset selector
                echo -e $TEXT_YELLOW && echo "Installing necessary packages..." && echo -e $TEXT_RESET
                sudo apt install software-properties-common curl jq -y
                sudo add-apt-repository ppa:certbot/certbot -y > /dev/null
                sudo apt update && sudo apt install python-certbot-nginx -y
                sudo apt update && sudo apt dist-upgrade -y && sudo apt upgrade -y && apt autoremove -y

                echo -e $TEXT_YELLOW && echo "Updating Nginx..." && echo -e $TEXT_RESET
                sudo mkdir /etc/systemd/system/nginx.service.d
                sudo printf "[Service]\nExecStartPost=/bin/sleep 0.1\n" > /etc/systemd/system/nginx.service.d/override.conf
                sudo systemctl daemon-reload

                echo -e $TEXT_YELLOW && echo "Downloading Nginx configuration..." && echo -e $TEXT_RESET
                sudo wget -q -O /etc/nginx/sites-available/default https://raw.githubusercontent.com/TangleBay/hornet-light-installer/master/configs/nginx.conf

                # Variables
                $setdomain && $settrinityport && $setdashport && $sethashsize

                echo -e $TEXT_YELLOW && echo "Starting SSL-Certificate installation..." && echo -e $TEXT_RESET
                sudo systemctl restart nginx
                sudo certbot --nginx -d $domain

                if [ -f "/etc/letsencrypt/live/$domain/fullchain.pem" ]; then
                    sudo find /etc/nginx/sites-available/default -type f -exec sed -i 's/\#RjtV27dw/''/g' {} \;
                    sudo systemctl restart nginx
                fi

                echo -e $TEXT_YELLOW && echo "Reverse proxy installation finished!" && echo -e $TEXT_RESET
                echo -e $TEXT_RED_B && pause 'Press [Enter] key to continue...'
                echo -e $TEXT_RESET
            fi
            if [ "$selector" = "b" ] || [ "$selector" = "B" ]; then
                unset selector
                let selectcounter=selectcounter+1
            fi
        done
    if [ "$selector" = "x" ] || [ "$selector" = "X" ]; then
        let counter=counter+1
    fi
done
clear
exit 0