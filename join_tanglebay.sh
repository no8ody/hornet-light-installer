#!/bin/bash

# Please configure your settings
name=my node name
domain=my.domain.tld
port=443

# Set if your node should do pow
pow=true

# You use already a reverse proxy?
proxy=false

# If you had no password before, please let it empty
password=


############################################################################################################################################################
############################################################################################################################################################
# DO NOT EDIT THE LINES BELOW !!!
############################################################################################################################################################
############################################################################################################################################################
TEXT_RESET='\e[0m'
TEXT_YELLOW='\e[0;33m'
TEXT_RED_B='\e[1;31m'

if [ $proxy == true ]
then
  sudo apt update && apt install curl jq -y
  curl https://community.tanglebay.org/nodes -X POST -H 'Content-type: application/json' -d '{"name": "$name", "url": "https://$domain:$port", "pow": $pow}' |jq
  echo -e $TEXT_YELLOW
  echo "Please write down your node password, so you can later remove your node if you want it.
  echo -e $TEXT_RESET
fi
if [ $proxy == false ]
then
  echo -e $TEXT_RED_B
  echo "You need first to set up a reverse proxy for your node wit https enabled!
  echo -e $TEXT_RESET
fi
exit 0
  
