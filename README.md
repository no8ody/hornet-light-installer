# Hornet Lightwight Installer #

**Download the latest release version of the script and run it. Do the following steps:**

1. `sudo wget -O hornet-installer.sh https://raw.githubusercontent.com/TangleBay/hornet-light-installer/master/hornet-installer.sh`
2. `sudo chmod +x install-hornet.sh`
3. Edit your preferences in the config section: `sudo nano hornet-installer.sh` 
4. Run the installer: `sudo ./hornet-installer.sh`

**After your node is running you need to add some neighbors in the config.json file**

`sudo nano /home/iota/hornet/config.json`

**After you have added some neighbors just restart the node to get sync**

`sudo systemctl restart hornet`

# Update your Hornet node #

**To update your hornet node just run the installer again**
- `sudo ./hornet-installer.sh`
