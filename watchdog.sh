#!/bin/bash
check="$(systemctl show -p ActiveState --value hornet)"

if [ "$check" = "active" ]; then
    latesthornet="$(curl -s https://api.github.com/repos/gohornet/hornet/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')"
    latesthornet="${latesthornet:1}"
    nodev="$(curl -s http://127.0.0.1:14265 -X POST -H 'Content-Type: application/json' -H 'X-IOTA-API-Version: 1' -d '{"command": "getNodeInfo"}' | jq '.appVersion')"
    version="${nodev%\"}"
    version="${version#\"}"
    if [ "$version" != "$latesthornet" ]; then
        sudo systemctl stop hornet
        sudo mv /home/$user/hornet/neighbors.json /home/$user/hornet/neighbors.json.bak
        sudo mv /home/$user/hornet/config.json /home/$user/hornet/config.json.bak
        sudo wget -qO- https://github.com/gohornet/hornet/releases/download/v$latesthornet/HORNET-"$latesthornet"_Linux_"$os".tar.gz | sudo tar -xzf - -C /home/$user/hornet
        sudo mv /home/$user/hornet/neighbors.json.bak /home/$user/hornet/neighbors.json
        sudo mv /home/$user/hornet/config.json.bak /home/$user/hornet/config.json
        sudo chown -R $user:$user /home/$user/hornet
        sudo chmod 770 /home/$user/hornet/hornet
        sudo systemctl start hornet
    fi
fi

if [ "$check" != "active" ]; then
    snapshot="$(curl -s https://raw.githubusercontent.com/TangleBay/hornet-light-installer/master/snapshot)"
    dt=`date '+%m/%d/%Y %H:%M:%S'`
    sudo systemctl stop hornet
    sudo rm -r /home/$user/hornet/mainnetdb
    sudo -u $user wget -O /home/$user/hornet/latest-export.gz.bin $snapshot
    sudo systemctl restart hornet
    counter="$(cat /root/watchdog.log | sed -n -e '1{p;q}')"
    let counter=counter+1
    {
    echo $counterg
    echo $dt
    } > /root/watchdog.log
    counter=0
fi
exit 0