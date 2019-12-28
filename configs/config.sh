#!/usr/bin/env bash

# Welcome to the Hornet leightweight installer!
# Please enter your desired values into the configuration accordingly. Afterwards please run the script again.
# If you have any questions about the individual steps, please have a look at the readme at https://github.com/TangleBay/hornet-light-installer.
# Have fun with your Hornet node! 


############################################################################################################################################################
# CONFIG FOR THE HORNET INSTALLER
############################################################################################################################################################

os=ARM                      # ARM = Raspberry PI3+/4 (32bit) | x86_64 = VPS/Root (64bit)
user=iota                   # You can specify a own username for the hornet node
profile=1gb                 # Please set your profile in RAM-GB (PI3B+/4=1gb, PI4=2gb, 4gb, 8gb)

# If you cannot occupy one of the remaining slots, please leave the default values.
neighbor1=neighbor1:15600   
neighbor2=neighbor2:15600
neighbor3=neighbor3:15600
neighbor4=neighbor4:15600
neighbor5=neighbor5:15600


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