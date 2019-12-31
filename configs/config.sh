#!/usr/bin/env bash

# Welcome to the Hornet leightweight installer!
# Please enter your desired values into the configuration accordingly. Afterwards please run the script again.
# If you have any questions about the individual steps, please have a look at the readme at https://github.com/TangleBay/hornet-light-installer.
# Have fun with your Hornet node!


############################################################################################################################################################
# CONFIG FOR THE HORNET INSTALLER
############################################################################################################################################################

# ARM = Raspberry PI3+/4 (DietPi 32bit) | ARM64 = Raspberry4 4GB (Ubuntu 64bit) | x86_64 = VPS/Root (64bit)
os=ARM

# You can specify a own username for the hornet node
user=iota

# Please set your profile in RAM-GB (PI3B+/4(x86)=1gb, PI4(Ubuntu64)=2gb or default = auto
profile=1gb

# Define if a username and password is required for the dashboard
dashauth=false

# For the Dashboard access please define a username and a password below
dashuser="hornella"
dashpw="hornatella"

# If you cannot occupy one of the remaining slots, please leave the default values. You shouldn't have more than 5 neighbors.
# Please replace the defined neighbors below as soon as possible
neighbor1=auto01.manapotion.io:15601
neighbor2=auto02.manapotion.io:15602
neighbor3=node01.iotatoken.nl:14700


############################################################################################################################################################
# CONFIG FOR THE PROXY INSTALLER
############################################################################################################################################################

# Set your domain or your ddns name
domain=myhornetnode.ddns.net

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