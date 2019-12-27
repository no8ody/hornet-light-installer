#!/bin/bash

############################################################################################################################################################
# CONFIG FOR THE HORNET INSTALLER
############################################################################################################################################################

os=ARM                  # ARM = Raspberry PI3+/4 (32bit) | x86_64 = VPS/Root (64bit)
user=iota               # You can specify a own username for the hornet node

############################################################################################################################################################
# CONFIG FOR THE PROXY INSTALLER
############################################################################################################################################################

domain=my.domain.tld   # Set your domain or your ddns name
trinityport=14266      # Set your prefered Trinity port (this port must be exposed in your router if you want to reach it from outside)
dashport=14267         # Set your prefered dashboard port (this port must be exposed in your router if you want to reach it from outside)


############################################################################################################################################################
# CONFIG FOR THE TANGLE BAY INSTALLER
############################################################################################################################################################

name="My Awesome Hornet Node"   # Set your prefered shown node name
pow=true                        # Set if your node should do proof of work in the pool
password=""                     # Set your password after adding your node so you can remove it later






############################################################################################################################################################
############################################################################################################################################################
# DO NOT EDIT THE LINES BELOW !!! DO NOT EDIT THE LINES BELOW !!! DO NOT EDIT THE LINES BELOW !!! DO NOT EDIT THE LINES BELOW !!!
############################################################################################################################################################
############################################################################################################################################################

TEXT_RESET='\e[0m'
TEXT_YELLOW='\e[0;33m'
TEXT_RED_B='\e[1;31m'
clear

echo -e $TEXT_YELLOW && echo "Welcome to the Hornet lightweight installer!" && echo -e $TEXT_RESET
echo -e $TEXT_YELLOW && echo "Please choose what you want to do:" && echo -e $TEXT_RESET
echo -e $TEXT_YELLOW
echo "1) Update the hornet node"
echo "2) Install the hornet node"
echo "3) Install the reverse proxy"
echo "4) Add your node to Tangle Bay"
echo "5) Remove your node from Tangle Bay"
echo "6) Exit"
echo -e $TEXT_RESET
echo -e $TEXT_YELLOW && read -p "Please type in the number: " selector
echo -e $TEXT_RESET

if [ "$selector" = "1" ] ; then
	echo -e $TEXT_YELLOW && echo "Get latest hornet version..." && echo -e $TEXT_RESET
	version="$(curl -s https://api.github.com/repos/gohornet/hornet/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')"
	version="${version:1}"
	echo -e $TEXT_RED_B && echo "Latest Version: $version" && echo -e $TEXT_RESET
	echo -e $TEXT_YELLOW && echo "Stopping hornet node...(Please note that this may take some time)" && echo -e $TEXT_RESET
	sudo systemctl stop hornet
	echo -e $TEXT_YELLOW && echo "Downloading new hornet file..." && echo -e $TEXT_RESET
	sudo wget -O /tmp/HORNET-"$version"_Linux_"$os".tar.gz https://github.com/gohornet/hornet/releases/download/v$version/HORNET-"$version"_Linux_"$os".tar.gz
	sudo tar -xzf /tmp/HORNET-"$version"_Linux_"$os".tar.gz -C /tmp
	sudo mv /tmp/HORNET-"$version"_Linux_"$os"/hornet /home/$user/hornet/
	sudo rm -r /tmp/HORNET-"$version"_Linux_"$os"*
	sudo chown $user:$user /home/$user/hornet/hornet
	sudo chmod 770 /home/$user/hornet/hornet
	echo -e $TEXT_YELLOW && echo "Starting hornet node...(Please note that this may take some time)" && echo -e $TEXT_RESET
	sudo systemctl start hornet
	echo -e $TEXT_RED_B && echo "Update finished...Bye!" && echo -e $TEXT_RESET
	exit 0
fi

if [ "$selector" = "2" ]; then
    echo -e $TEXT_YELLOW && echo "Installing necessary packages..." && echo -e $TEXT_RESET
    sudo apt install nano curl jq -y
    version="$(curl -s https://api.github.com/repos/gohornet/hornet/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')"
    version="${version:1}"

    echo -e $TEXT_YELLOW && echo "Starting installation of hornet" && echo -e $TEXT_RESET
    sudo useradd -m $user
    sudo mkdir /home/$user > /dev/null && sudo chown $user:$user /home/$user
    sudo usermod -d /home/$user -m $user
    sudo -u $user mkdir /home/$user/hornet

    echo -e $TEXT_YELLOW && echo "Downloading hornet files..." && echo -e $TEXT_RESET
    sudo wget -O /tmp/HORNET-"$version"_Linux_"$os".tar.gz https://github.com/gohornet/hornet/releases/download/v$version/HORNET-"$version"_Linux_"$os".tar.gz
    sudo tar -xzf /tmp/HORNET-"$version"_Linux_"$os".tar.gz -C /tmp
    sudo mv /tmp/HORNET-"$version"_Linux_"$os"/* /home/$user/hornet/
    sudo rm -r /tmp/HORNET-"$version"_Linux_"$os"*
    sudo wget -O /home/$user/hornet/latest-export.gz.bin https://dbfiles.iota.org/mainnet/hornet/latest-export.gz.bin
    sudo wget -O /home/$user/hornet/config.json https://raw.githubusercontent.com/TangleBay/hornet-light-installer/master/configs/hornet.conf
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
    sudo systemctl start hornet
    sudo systemctl status hornet

    echo -e $TEXT_RED_B && echo "Finish up hornet installation...done. Bye bye!" && echo -e $TEXT_RESET
    exit 0
fi

if [ "$selector" = "3" ]; then
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
    sudo wget -O /etc/nginx/sites-available/default https://raw.githubusercontent.com/TangleBay/hornet-light-installer/master/configs/nginx.conf
    sudo find /etc/nginx/sites-available/default -type f -exec sed -i 's/domain.tld/'$domain'/g' {} \;
    sudo find /etc/nginx/sites-available/default -type f -exec sed -i 's/14266/'$trinityport'/g' {} \;
    sudo find /etc/nginx/sites-available/default -type f -exec sed -i 's/14267/'$dashport'/g' {} \;
    sudo systemctl restart nginx

    echo -e $TEXT_YELLOW && echo "Starting SSL-Certificate installation..." && echo -e $TEXT_RESET
    sudo certbot --nginx -d $domain
    sslcertpath=ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
    sslcertkeypath=ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;
    
    sudo find /etc/nginx/sites-available/default -type f -exec sed -i 's/##SSLCERT/'$sslcertpath'/g' {} \;
    sudo find /etc/nginx/sites-available/default -type f -exec sed -i 's/##SSLCERTKEY/'$sslcertkeypath'/g' {} \;
    echo -e $TEXT_RED_B && echo "Reverse proxy installation finished... Bye!" && echo -e $TEXT_RESET
    exit 0
fi

if [ "$selector" = "4" ]; then
    curl https://community.tanglebay.org/nodes -X POST -H 'Content-type: application/json' -d '{"name": $name, "url": "https://$domain:$trinityport", "pow": $pow}' |jq
    exit 0
fi

if [ "$selector" = "5" ]; then
	curl -X DELETE http://community.tanglebay.org/nodes/$password
fi

if [ "$selector" = "6" ]; then
    exit 0
fi
exit 0