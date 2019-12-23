#!/usr/bin/env bash


####################################################################
# CONFIG FOR HORNET INSTALLER
####################################################################

# ARM = Raspberry PI3+/4 | x86_64 = VPS
os=ARM

# You can specify a own username for the hornet node
user=iota

####################################################################
# CONFIG FOR TANGLEBAY SWARM
####################################################################

# Please configure your settings
name="my node name"
domain=my.domain.tld
port=443

# Set if your node should do pow
pow=true

# You use already a reverse proxy?
proxy=false

# If you had no password before, please let it empty
password=
