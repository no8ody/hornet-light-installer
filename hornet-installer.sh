#!/bin/bash

############################################################################################################################################################
############################################################################################################################################################
# DO NOT EDIT THE LINES BELOW !!! DO NOT EDIT THE LINES BELOW !!! DO NOT EDIT THE LINES BELOW !!! DO NOT EDIT THE LINES BELOW !!!
############################################################################################################################################################
############################################################################################################################################################
version=0.2.0

TEXT_RESET='\e[0m'
TEXT_YELLOW='\e[0;33m'
TEXT_RED_B='\e[1;31m'
yellow='\e[33m'
green='\e[32m'
red='\e[31m'
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

snapshot="$(curl -s https://raw.githubusercontent.com/TangleBay/hornet-light-installer/master/snapshot)"
latesthornet="$(curl -s https://api.github.com/repos/gohornet/hornet/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')"
latesthornet="${latesthornet:1}"
latesthli="$(curl -s https://api.github.com/repos/TangleBay/hornet-light-installer/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')"

############################################################################################################################################################

if [ $(id -u) -ne 0 ]; then 
    echo -e $TEXT_RED_B "Please run HLI with sudo or as root"
    echo -e $TEXT_RED_B && pause ' Press [Enter] key to continue...'
    echo -e $TEXT_RESET
    exit 0
fi


if [ "$version" != "$latesthli" ]; then
    echo -e $TEXT_RED_B && echo " New version available (v$latesthli)! Downloading new version..." && echo -e $TEXT_RESET
    sudo wget -q -O hornet-installer.sh https://raw.githubusercontent.com/TangleBay/hornet-light-installer/master/hornet-installer.sh
    sudo chmod +x hornet-installer.sh
    echo -e $TEXT_YELLOW && echo "Backup current HLI config..." && echo -e $TEXT_RESET
    ScriptLoc=$(readlink -f "$0")
    exec "$ScriptLoc"
    exit 0
fi

if [ ! -f "config.sh" ]; then
    echo -e $TEXT_YELLOW && echo " First run detected...Downloading config file!" && echo -e $TEXT_RESET
    sudo wget -q -O config.sh https://raw.githubusercontent.com/TangleBay/hornet-light-installer/master/config.sh
    sudo nano config.sh
fi

counter=0
while [ $counter -lt 1 ]; do
    clear
    source config.sh
    nodetempv="$(curl -s http://127.0.0.1:14265 -X POST -H 'Content-Type: application/json' -H 'X-IOTA-API-Version: 1' -d '{"command": "getNodeInfo"}' | jq '.appVersion')"
    rlmi="$(curl -s https://nodes.tanglebay.org -X POST -H 'Content-Type: application/json' -H 'X-IOTA-API-Version: 1' -d '{"command": "getNodeInfo"}' | jq '.latestMilestoneIndex')"
    llmi="$(curl -s http://127.0.0.1:14265 -X POST -H 'Content-Type: application/json' -H 'X-IOTA-API-Version: 1' -d '{"command": "getNodeInfo"}' | jq '.latestSolidSubtangleMilestoneIndex')"

    nodev="${nodetempv%\"}"
    nodev="${nodev#\"}"
    let rlmi=rlmi+0
    let llmi=llmi+0

    sudo crontab -l | grep -q '/root/watchdog'  && watchdog=active || watchdog=inactive
    if [ -f "/root/watchdog.log" ]; then
        watchdogcount="$(cat /root/watchdog.log | sed -n -e '1{p;q}')"
        watchdogtime="$(cat /root/watchdog.log | sed -n -e '2{p;q}')"
    fi

    ############################################################################################################################################################

    echo ""
    echo -e $yellow "\033[1m\033[4mWelcome to the (HLI) Hornet lightweight installer! [v$version]\033[0m"
    echo ""
    if [ -n "$nodev" ]; then
        if [ "$nodev" == "$latesthornet" ]; then
            echo -e "$yellow Version:$green $nodev"
        else
            echo -e "$yellow Version:$red $nodev"
        fi
    else
        echo -e "$yellow Version:$red N/A"
    fi
    echo ""
    if [ -n "$nodev" ]; then
        let lmi=$rlmi-$llmi
        if [ $lmi -gt 4 ]; then
            echo -e "$yellow Status:$red not synced"
            echo -e "$yellow Delay: $red$lmi$yellow milestone(s)"
        else
            echo -e "$yellow Status:$green synced"
            echo -e "$yellow Delay: $lmi$yellow milestone(s)"
        fi
    else
        echo -e "$yellow Status:$red offline"
    fi
    echo ""
    if [ "$watchdog" != "active" ]; then
        echo -e "$yellow Watchdog:$red $watchdog"
    else
        echo -e "$yellow Watchdog:$green $watchdog"
        echo -e "$yellow Restarts:$red $watchdogcount"
        if [ -n "$watchdogtime" ]; then
            echo -e "$yellow Last restart: $watchdogtime"
        fi
    fi
    echo ""

    echo -e "\e[90m==========================================================="
    echo ""
    echo -e $red "\033[1m\033[4mHLI Management\033[0m"
    echo ""
    echo -e $yellow
    echo " 1) Hornet Manager"
    echo ""
    echo " 2) Tangle Bay Manager"
    echo ""
    echo " 3) Install Manager"
    echo ""
    echo -e "\e[90m-----------------------------------------------------------"
    echo ""
    echo -e $yellow "x) Exit"
    echo ""
    echo -e "\e[90m==========================================================="
    echo -e $TEXT_YELLOW && read -t 30 -p " Please type in your option: " selector
    echo -e $TEXT_RESET

    if [ "$selector" = "1" ] ; then
        counter1=0
        while [ $counter1 -lt 1 ]; do
            clear
            echo ""
            echo -e $red "\033[1m\033[4mHornet Manager\033[0m"
            echo -e $yellow ""
            echo " 1) Control hornet (start/stop)"
            echo " 2) Show last live log"
            echo " 3) Edit neighbors.json"
            echo " 4) Edit config.json"
            echo " 5) Update the hornet node"
            echo " 6) Delete mainnet database"
            echo " 7) Manage watchdog"
            echo ""
            echo -e "\e[90m-----------------------------------------------------------"
            echo ""
            echo -e $yellow "x) Back"
            echo ""
            echo -e "\e[90m==========================================================="
            echo -e $TEXT_YELLOW && read -p " Please type in your option: " selector
            echo -e $TEXT_RESET
            if [ "$selector" = "1" ] ; then
                echo -e $TEXT_RED_B && read -p " Would you like to (r)estart/(h)stop/(s)tatus or (c)ancel: " selector1
                echo -e $TEXT_RESET
                if [ "$selector1" = "r" ] || [ "$selector1" = "R" ]; then
                    unset selector1
                    sudo systemctl restart hornet
                    echo -e $TEXT_YELLOW && echo " Hornet node (re)started!" && echo -e $TEXT_RESET
                    echo -e $TEXT_RED_B && pause ' Press [Enter] key to continue...'
                    echo -e $TEXT_RESET
                fi
                if [ "$selector1" = "h" ] || [ "$selector1" = "H" ]; then
                    unset selector1
                    sudo systemctl stop hornet
                    echo -e $TEXT_YELLOW && echo " Hornet node stopped!" && echo -e $TEXT_RESET
                    echo -e $TEXT_RED_B && pause ' Press [Enter] key to continue...'
                    echo -e $TEXT_RESET
                fi
                if [ "$selector1" = "s" ] || [ "$selector1" = "S" ]; then
                    unset selector1
                    sudo systemctl status hornet
                    echo -e $TEXT_RED_B && pause ' Press [Enter] key to continue...'
                    echo -e $TEXT_RESET
                fi
            fi

            if [ "$selector" = "2" ] ; then
                sudo journalctl -fu hornet | less -FRSXM
            fi

            if [ "$selector" = "3" ] ; then
                if [ ! -f "/home/$user/hornet/neighbors.json" ]; then
                    echo -e $TEXT_YELLOW && echo " No neighbors.json found...Downloading config file!" && echo -e $TEXT_RESET
                    sudo -u $user wget -q -O /home/$user/hornet/neighbors.json https://raw.githubusercontent.com/gohornet/hornet/master/neighbors.json
                    sudo sed -i 's/\"example1.neighbor.com:15600\"/\"'$neighbor1'\"/g' /home/$user/hornet/neighbors.json
                    sudo sed -i 's/\"example2.neighbor.com:15600\"/\"'$neighbor2'\"/g' /home/$user/hornet/neighbors.json
                    sudo sed -i 's/\"example3.neighbor.com:15600\"/\"'$neighbor3'\"/g' /home/$user/hornet/neighbors.json
                fi
                sudo nano /home/$user/hornet/neighbors.json
                echo -e $TEXT_YELLOW && echo " Neighbors configuration changed!" && echo -e $TEXT_RESET
                echo -e $TEXT_RED_B && pause ' Press [Enter] key to continue...'
                echo -e $TEXT_RESET

            fi

            if [ "$selector" = "4" ] ; then
                sudo nano /home/$user/hornet/config.json
                echo -e $TEXT_RED_B && read -p " Would you like to restart hornet now (y/N): " selector4
                if [ "$selector4" = "y" ] || [ "$selector4" = "y" ]; then
                    sudo systemctl restart hornet
                    echo -e $TEXT_YELLOW && echo " Hornet node restarted!" && echo -e $TEXT_RESET
                    echo -e $TEXT_RED_B && pause ' Press [Enter] key to continue...'
                    echo -e $TEXT_RESET
                fi
            fi

            if [ "$selector" = "5" ] ; then
                latesthornet="$(curl -s https://api.github.com/repos/gohornet/hornet/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')"
                latesthornet="${latesthornet:1}"
                echo -e $TEXT_YELLOW && echo " Get latest hornet version..." && echo -e $TEXT_RESET
                echo -e $TEXT_YELLOW && echo " Stopping hornet node...(Please note that this may take some time)" && echo -e $TEXT_RESET
                sudo systemctl stop hornet
                echo -e $TEXT_YELLOW && echo " Downloading new hornet file..." && echo -e $TEXT_RESET
                sudo wget -qO- https://github.com/gohornet/hornet/releases/download/v$latesthornet/HORNET-"$latesthornet"_Linux_"$os".tar.gz | sudo tar -xzf - -C /home/$user/hornet
                sudo mv /home/$user/hornet/HORNET-"$latesthornet"_Linux_"$os"/hornet /home/$user/hornet/
                echo -e $TEXT_YELLOW && echo " Backup current hornet config file..." && echo -e $TEXT_RESET
                sudo mv /home/$user/hornet/config.json /home/$user/hornet/config.json.bak
                sudo mv /home/$user/hornet/HORNET-"$latesthornet"_Linux_"$os"/config.json /home/$user/hornet/
                sudo sed -i 's/\"useProfile\": \"auto\"/\"useProfile\": \"'$profile'\"/g' /home/$user/hornet/config.json
                sudo sed -i 's/\"enabled\": false/\"enabled\": '$dashauth'/g' /home/$user/hornet/config.json
                sudo sed -i 's/\"username\": "hornet"/\"username\": \"'$dashuser'\"/g' /home/$user/hornet/config.json
                sudo sed -i 's/\"password\": "hornet"/\"password\": \"'$dashpw'\"/g' /home/$user/hornet/config.json
                sudo sed -i 's/\"port\": 15600/\"port\": '$nbport'/g' /home/$user/hornet/config.json
                sudo rm -rf /home/$user/hornet/HORNET-"$latesthornet"_Linux_"$os"*
                sudo chown -R $user:$user /home/$user/hornet/
                sudo chmod 770 /home/$user/hornet/hornet
                if [ ! -f "/home/$user/hornet/neighbors.json" ]; then
                    echo -e $TEXT_YELLOW && echo " No neighbors.json found...Downloading config file!" && echo -e $TEXT_RESET
                    sudo -u $user wget -q -O /home/$user/hornet/neighbors.json https://raw.githubusercontent.com/gohornet/hornet/master/neighbors.json
                    sudo sed -i 's/\"example1.neighbor.com:15600\"/\"'$neighbor1'\"/g' /home/$user/hornet/neighbors.json
                    sudo sed -i 's/\"example2.neighbor.com:15600\"/\"'$neighbor2'\"/g' /home/$user/hornet/neighbors.json
                    sudo sed -i 's/\"example3.neighbor.com:15600\"/\"'$neighbor3'\"/g' /home/$user/hornet/neighbors.json
                    sudo nano /home/$user/hornet/neighbors.json
                fi
                sudo systemctl start hornet
                echo -e $TEXT_RED_B && pause ' Press [Enter] key to continue...'
                echo -e $TEXT_RESET
            fi

            if [ "$selector" = "6" ]; then
                sudo systemctl stop hornet
                sudo rm -rf /home/$user/hornet/mainnetdb/
                echo -e $TEXT_RED_B && read -p " Would you like to download the latest snapshot (y/N): " selector6
                echo -e $TEXT_RESET
                if [ "$selector6" = "y" ] || [ "$selector6" = "Y" ]; then
                    echo -e $TEXT_YELLOW && echo " Downloading snapshot file..." && echo -e $TEXT_RESET
                    sudo -u $user wget -O /home/$user/hornet/latest-export.gz.bin $snapshot
                fi
                sudo systemctl restart hornet
                echo -e $TEXT_YELLOW && echo " Reset of the database finished and hornet restarted!" && echo -e $TEXT_RESET
                echo -e $TEXT_RED_B && pause ' Press [Enter] key to continue...'
                echo -e $TEXT_RESET
            fi

            if [ "$selector" = "7" ]; then
                echo -e $TEXT_RED_B && read -p " Would you like to (e)nable/(d)isable or (c)ancel hornet watchdog: " selector7
                echo -e $TEXT_RESET
                croncmd="/root/watchdog.sh"
                cronjob="*/15 * * * * $croncmd"
                if [ "$selector7" = "e" ] || [ "$selector7" = "E" ]; then
                    echo -e $TEXT_YELLOW && echo " Enable hornet watchdog..." && echo -e $TEXT_RESET
                    sudo echo "0" > /root/watchdog.log
                    sudo wget -q -O /root/watchdog.sh https://raw.githubusercontent.com/TangleBay/hornet-light-installer/master/watchdog.sh
                    sudo chmod 700 /root/watchdog.sh
                    sudo sed -i 's/$user/'$user'/g' /root/watchdog.sh
                    sudo sed -i 's/$os/'$os'/g' /root/watchdog.sh
                    ( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
                fi
                if [ "$selector7" = "d" ] || [ "$selector7" = "D" ]; then
                    echo -e $TEXT_YELLOW && echo " Disable hornet watchdog..." && echo -e $TEXT_RESET
                    ( crontab -l | grep -v -F "$croncmd" ) | crontab -
                    ( crontab -l | grep -v -F "/root/watchdog" ) | crontab -
                    sudo rm -rf /root/watchdog
                fi
                echo -e $TEXT_YELLOW && echo " Hornet watchdog configuration finished!" && echo -e $TEXT_RESET
                echo -e $TEXT_RED_B && pause ' Press [Enter] key to continue...'
                echo -e $TEXT_RESET
            fi
            if [ "$selector" = "x" ] || [ "$selector" = "X" ]; then
                counter1=1
            fi
        done
        unset selector
    fi

    ############################################################################################################################################################

    if [ "$selector" = "2" ]; then
        counter2=0
        while [ $counter2 -lt 1 ]; do
            clear
            echo ""
            echo -e $red "\033[1m\033[4mTangle Bay Manager\033[0m"
            echo -e $yellow ""
            echo " 1) Add your node to Tangle Bay"
            echo " 2) Remove your node from Tangle Bay"
            echo " 3) Update node on Tangle Bay"
            echo ""
            echo -e "\e[90m-----------------------------------------------------------"
            echo ""
            echo -e $yellow "x) Back"
            echo ""
            echo -e "\e[90m==========================================================="
            echo -e $TEXT_YELLOW && read -p " Please type in your option: " selector
            echo -e $TEXT_RESET
            if [ "$selector" = "1" ]; then
                domain2=https://$domain:$trinityport
                curl -X POST "https://register.tanglebay.org/nodes" -H  "accept: */*" -H  "Content-Type: application/json" -d "{ \"name\": \"$name\", \"url\": \"$domain2\", \"address\": \"$donationaddress\", \"pow\": \"$pow\" }" |jq
                echo -e $TEXT_RED_B && pause ' Press [Enter] key to continue...'
                echo -e $TEXT_RESET
            fi
            if [ "$selector" = "2" ]; then
                curl -X DELETE https://register.tanglebay.org/nodes/$password |jq
                echo -e $TEXT_RED_B && pause ' Press [Enter] key to continue...'
                echo -e $TEXT_RESET
            fi
            if [ "$selector" = "3" ]; then
                curl --silent --output /dev/null -X DELETE https://register.tanglebay.org/nodes/$password
                domain2=https://$domain:$trinityport
                curl -X POST "https://register.tanglebay.org/nodes" -H  "accept: */*" -H  "Content-Type: application/json" -d "{ \"name\": \"$name\", \"url\": \"$domain2\", \"address\": \"$donationaddress\", \"pow\": \"$pow\", \"password\": \"$password\" }" |jq
                echo -e $TEXT_RED_B && pause ' Press [Enter] key to continue...'
                echo -e $TEXT_RESET
            fi
            if [ "$selector" = "x" ] || [ "$selector" = "X" ]; then
                counter2=1
            fi
        done
        unset selector
    fi

    if [ "$selector" = "3" ]; then
        counter3=0
        while [ $counter3 -lt 1 ]; do
            clear
            echo ""
            echo -e $red "\033[1m\033[4mInstaller Manager\033[0m"
            echo -e $yellow ""
            echo " 1) Install hornet node"
            echo " 2) Install nginx reverse proxy"
            echo " 3) Download latest HLI config"
            echo " 4) Edit HLI config"
            echo ""
            echo -e "\e[90m-----------------------------------------------------------"
            echo ""
            echo -e $yellow "x) Back"
            echo ""
            echo -e "\e[90m==========================================================="
            echo -e $TEXT_YELLOW && read -p " Please type in your option: " selector
            echo -e $TEXT_RESET
            if [ "$selector" = "1" ]; then
                latesthornet="$(curl -s https://api.github.com/repos/gohornet/hornet/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')"
                latesthornet="${latesthornet:1}"
                echo -e $TEXT_YELLOW && echo " Installing necessary packages..." && echo -e $TEXT_RESET
                sudo apt install nano -y

                echo -e $TEXT_YELLOW && echo " Starting installation of hornet" && echo -e $TEXT_RESET
                sudo useradd -m $user
                sudo mkdir /home/$user > /dev/null && sudo chown $user:$user /home/$user
                sudo usermod -d /home/$user -m $user
                sudo -u $user mkdir /home/$user/hornet

                echo -e $TEXT_YELLOW && echo " Downloading hornet files..." && echo -e $TEXT_RESET
                sudo wget -qO- https://github.com/gohornet/hornet/releases/download/v$latesthornet/HORNET-"$latesthornet"_Linux_"$os".tar.gz | sudo tar -xzf - -C /home/$user/hornet
                sudo mv /home/$user/hornet/HORNET-"$latesthornet"_Linux_"$os"/* /home/$user/hornet/
                sudo rm -rf /home/$user/hornet/HORNET-"$latesthornet"_Linux_"$os"*
                sudo -u $user wget -O /home/$user/hornet/latest-export.gz.bin $snapshot
                sudo sed -i 's/\"useProfile\": \"auto\"/\"useProfile\": \"'$profile'\"/g' /home/$user/hornet/config.json
                sudo sed -i 's/\"enabled\": false/\"enabled\": '$dashauth'/g' /home/$user/hornet/config.json
                sudo sed -i 's/\"username\": "hornet"/\"username\": \"'$dashuser'\"/g' /home/$user/hornet/config.json
                sudo sed -i 's/\"password\": "hornet"/\"password\": \"'$dashpw'\"/g' /home/$user/hornet/config.json
                sudo sed -i 's/\"port\": 15600/\"port\": '$nbport'/g' /home/$user/hornet/config.json
                sudo sed -i 's/\"example1.neighbor.com:15600\"/\"'$neighbor1'\"/g' /home/$user/hornet/neighbors.json
                sudo sed -i 's/\"example2.neighbor.com:15600\"/\"'$neighbor2'\"/g' /home/$user/hornet/neighbors.json
                sudo sed -i 's/\"example3.neighbor.com:15600\"/\"'$neighbor3'\"/g' /home/$user/hornet/neighbors.json
                sudo -u $user mkdir /home/$user/hornet/mainnetdb
                sudo chown -R $user:$user /home/$user/hornet
                sudo chmod 770 /home/$user/hornet/hornet

                echo -e $TEXT_YELLOW && echo " Creating service for hornet..." && echo -e $TEXT_RESET
                {
                echo "[Unit]"
                echo "Description=HORNET Fullnode"
                echo "After=network.target"
                echo ""
                echo "[Service]"
                echo "WorkingDirectory=/home/$user/hornet"
                echo "User=$user"
                echo "TasksMax=infinity"
                echo "KillSignal=SIGTERM"
                echo "TimeoutStopSec=infinity"
                echo "ExecStart=/home/$user/hornet/hornet -c config"
                echo "SyslogIdentifier=HORNET"
                echo "Restart=on-failure"
                echo "RestartSec=1200"
                echo ""
                echo "[Install]"
                echo "WantedBy=multi-user.target"
                echo "Alias=hornet.service"
                } > /lib/systemd/system/hornet.service

                echo -e $TEXT_YELLOW && echo " Activate hornet service..." && echo -e $TEXT_RESET
                sudo systemctl daemon-reload
                sudo systemctl enable hornet.service
                echo -e $TEXT_YELLOW && echo " Starting hornet node! (Please note that this may take some time)" && echo -e $TEXT_RESET
                sudo systemctl restart hornet
                sudo systemctl status hornet

                echo -e $TEXT_YELLOW && echo " Hornet installation finished!" && echo -e $TEXT_RESET
                echo -e $TEXT_RED_B && pause ' Press [Enter] key to continue...'
                echo -e $TEXT_RESET
            fi

            if [ "$selector" = "2" ]; then
                echo -e $TEXT_YELLOW && echo " Installing necessary packages..." && echo -e $TEXT_RESET
                sudo apt install software-properties-common curl jq -y
                sudo add-apt-repository ppa:certbot/certbot -y > /dev/null
                sudo apt update && sudo apt install python-certbot-nginx -y
                sudo apt update && sudo apt dist-upgrade -y && sudo apt upgrade -y && apt autoremove -y

                echo -e $TEXT_YELLOW && echo " Updating Nginx..." && echo -e $TEXT_RESET
                sudo mkdir /etc/systemd/system/nginx.service.d
                sudo printf "[Service]\nExecStartPost=/bin/sleep 0.1\n" > /etc/systemd/system/nginx.service.d/override.conf
                sudo systemctl daemon-reload

                echo -e $TEXT_YELLOW && echo " Downloading Nginx configuration..." && echo -e $TEXT_RESET
                sudo wget -q -O /etc/nginx/sites-available/default https://raw.githubusercontent.com/TangleBay/hornet-light-installer/master/nginx.conf
                sudo find /etc/nginx/sites-available/default -type f -exec sed -i 's/domain.tld/'$domain'/g' {} \;
                sudo find /etc/nginx/sites-available/default -type f -exec sed -i 's/14266/'$trinityport'/g' {} \;
                sudo find /etc/nginx/sites-available/default -type f -exec sed -i 's/14267/'$dashport'/g' {} \;
                sudo find /etc/nginx/nginx.conf -type f -exec sed -i 's/\# server_names_hash_bucket_size 64;/server_names_hash_bucket_size 64;/g' {} \;
                sudo systemctl restart nginx

                echo -e $TEXT_YELLOW && echo " Starting SSL-Certificate installation..." && echo -e $TEXT_RESET
                sudo certbot --nginx -d $domain

                if [ -f "/etc/letsencrypt/live/$domain/fullchain.pem" ]; then
                    sudo wget -q -O /etc/nginx/sites-available/default https://raw.githubusercontent.com/TangleBay/hornet-light-installer/master/nginx.conf
                    sudo find /etc/nginx/sites-available/default -type f -exec sed -i 's/domain.tld/'$domain'/g' {} \;
                    sudo find /etc/nginx/sites-available/default -type f -exec sed -i 's/14266/'$trinityport'/g' {} \;
                    sudo find /etc/nginx/sites-available/default -type f -exec sed -i 's/14267/'$dashport'/g' {} \;
                    sudo find /etc/nginx/sites-available/default -type f -exec sed -i 's/\#RjtV27dw/''/g' {} \;
                    sudo systemctl restart nginx
                fi
                echo -e $TEXT_YELLOW && echo " Reverse proxy installation finished!" && echo -e $TEXT_RESET
                echo -e $TEXT_RED_B && pause ' Press [Enter] key to continue...'
                echo -e $TEXT_RESET
            fi

            if [ "$selector" = "3" ]; then
                echo -e $TEXT_YELLOW && echo " Creating backup of the HLI config file..." && echo -e $TEXT_RESET
                sudo mv config.sh config.sh.bak
                echo -e $TEXT_YELLOW && echo " Finished! You can find the HLI backup config in the folder." && echo -e $TEXT_RESET
                sudo wget -q -O config.sh https://raw.githubusercontent.com/TangleBay/hornet-light-installer/master/config.sh
                echo -e $TEXT_YELLOW && echo " Downloading latest HLI config completed!" && echo -e $TEXT_RESET
                sudo nano config.sh
                echo -e $TEXT_RED_B && pause ' Press [Enter] key to continue...'
                echo -e $TEXT_RESET
            fi

            if [ "$selector" = "4" ]; then
                sudo nano config.sh
            fi

            if [ "$selector" = "x" ] || [ "$selector" = "X" ]; then
                counter3=1
            fi
        done
        unset selector
    fi

    if [ "$selector" = "x" ] || [ "$selector" = "X" ]; then
        counter=1
    fi
done
counter=0
clear
exit 0
