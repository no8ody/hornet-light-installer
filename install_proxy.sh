#!/bin/bash
source install_hornet.sh
TEXT_RESET='\e[0m'
TEXT_YELLOW='\e[0;33m'
TEXT_RED_B='\e[1;31m'

sudo add-apt-repository ppa:certbot/certbot -y > /dev/null
sudo apt update -y > /dev/null
sudo apt-get install python-certbot-nginx -y
sudo apt update -y > /dev/null && sudo apt dist-upgrade -y > /dev/null && sudo apt upgrade -y > /dev/null && sudo apt autoremove -y > /dev/null
sudo mkdir /etc/systemd/system/nginx.service.d && sudo printf "[Service]\nExecStartPost=/bin/sleep 0.1\n" > /etc/systemd/system/nginx.service.d/override.conf && sudo systemctl daemon-reload && sudo systemctl restart nginx 
sudo wget -O /etc/nginx/site-available/default https://raw.githubusercontent.com/TangleBay/hornet_light_installer/master/proxy/nginx.conf
sudo find /etc/nginx/site-available/default -type f -exec sed -i 's/$domain/"$domain"/g' {} \;
sudo certbot --nginx -d $domain
