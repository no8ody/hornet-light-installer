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



# Install reverse proxy #

**Before you can run the installation of the reverse proxy it is necessary that you have defined your domain in script before.**
**Also you need to open following ports in your router configuration: `80/TCP` (Letsencrypt-Auth)**

1. `sudo nano hornet-installer.sh` and set your domain
2. `sudo ./hornet-installer.sh` and run the script
3. Choose the 3. option
4. Enter your e-mail address for notifications from LetsEncrypt
5. Agree the terms with `A`
6. Choose `N` next
7. Select `1` for installing the certificate

**If you want to reach your node from an external IP (outside of your local network) you need to open the TCP port which is selected in the installer script (trinityport).**
**Also if you want to reach you dashboard from an external IP (outside of your local network) you need to open the TCP port which is selected in the installer script (dashport).**


# Tangle Bay Pool #

**I would be very happy if you would join the Tangle Bay Pool so that together we can provide a strong and reliable node to the ecosystem and thus the Trinity users.**

**To add your node to the pool please follow these steps:**
1. `sudo nano hornet-installer.sh` and set your node name and pow option
2. `sudo ./hornet-installer.sh` and run the script
3. Choose the 4. option
4. You get now a password! Please copy the password and save it.
5. You're done, welcome to the pool party!

**To remove your node from the pool please follow these steps:**
1. `sudo nano hornet-installer.sh` and set your password
2. `sudo ./hornet-installer.sh` and run the script
3. Choose the 5. option
4. If your node details shows up, your node was successfully removed.
5. Thank you very much for your participation in the pool!