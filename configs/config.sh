#!/usr/bin/env bash

# Welcome to the Hornet leightweight installer!
# Please enter your desired values into the configuration accordingly. Afterwards please run the script again.
# If you have any questions about the individual steps, please have a look at the readme at https://github.com/TangleBay/hornet-light-installer.
# Have fun with your Hornet node!


############################################################################################################################################################
# CONFIG FOR THE HORNET INSTALLER
############################################################################################################################################################

# ARM = Raspberry PI3+/4 (32bit) | x86_64 = VPS/Root (64bit)
os=ARM

# You can specify a own username for the hornet node
user=iota

# Please set your profile in RAM-GB (PI3B+/4=1gb, PI4=2gb, 4gb, 8gb) or default = auto
profile=auto

# If you cannot occupy one of the remaining slots, please leave the default values. You shouldn't have more than 5 neighbors.
neighbor1=neighbor1.domain.tld:15600
neighbor2=neighbor2.domain.tld:15600
neighbor3=neighbor3.domain.tld:15600
neighbor4=neighbor4.domain.tld:15600
neighbor5=neighbor5.domain.tld:15600


############################################################################################################################################################
# CONFIG FOR THE PROXY INSTALLER
############################################################################################################################################################

# Set your domain or your ddns name
domain=my.domain.tld

# Set your prefered Trinity port (this port must be exposed in your router if you want to reach it from outside)
trinityport=14266

# Set your prefered dashboard port (this port must be exposed in your router if you want to reach it from outside)
dashport=14267


############################################################################################################################################################
# CONFIG FOR THE TANGLE BAY INSTALLER
############################################################################################################################################################
# !!! IMPORTANT !!!
# You need first to set up the reverse proxy!!!

# Set your prefered shown node name
name="My Awesome Hornet Node"

# Set if your node should do proof of work in the pool
pow=true

# Set your password after adding your node so you can remove it later
password=""

############################################################################################################################################################
############################################################################################################################################################