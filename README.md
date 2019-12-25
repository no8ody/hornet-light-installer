# Hornet Lightwight Installer #

**Download the latest release version of the script and run it. Do the following steps:**

1. `sudo wget -O install_hornet.sh https://raw.githubusercontent.com/TangleBay/hornet_light_installer/master/install_hornet.sh`
2. `sudo chmod +x install_hornet.sh`
3. Edit in the config file in the config section and set your operating system: `sudo nano install_hornet.sh` 
4. Run the installer: `sudo ./install_hornet.sh`

**After your node is running you need to add some neighbors in the config.json file**

`sudo nano /home/iota/hornet/config.json`

**After you have added some neighbors just restart the node to get sync**

`sudo systemctl restart hornet`

# Update your Hornet node #

**To update your hornet node just run the installer again**
- `sudo ./install_hornet.sh`