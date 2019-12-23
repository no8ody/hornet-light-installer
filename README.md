**Hornet Lightwight Installer**

Download the latest release version of the script and run it.

`sudo wget https://github.com/TangleBay/hornet_light_installer/releases/download/v0.0.2/hornet_light_installer.tar.gz && sudo tar -xzf hornet_light_installer.tar.gz && cd hornet_light_installer && sudo ./install_hornet.sh`

After your node is running you need to add some neighbors in the config.json file

`sudo nano /home/iota/hornet/config.json`

After you have added some neighbors just restart the node to get sync

`sudo systemctl restart hornet`