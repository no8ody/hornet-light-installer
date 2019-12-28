#!/usr/bin/env bash

# Welcome to the Hornet leightweight installer!
#



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