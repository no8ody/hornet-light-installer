### Please note that you use this script at your own risk and that I will not be liable for any damages that may occur ###


# Hornet Lightwight Installer #

**Download the latest release version of the script and run it. Do the following steps:**

1. First you should create a folder for the script and config `sudo mkdir hornet-installer && cd hornet-installer`
2. `sudo wget -O hornet-installer.sh https://raw.githubusercontent.com/TangleBay/hornet-light-installer/master/hornet-installer.sh`
3. `sudo chmod +x hornet-installer.sh`
5. Run the installer: `sudo ./hornet-installer.sh`
6. With the first start no config is detected and it will downloaded automatically and opened to edit.


# Install reverse proxy #

**Before you can run the installation of the reverse proxy it is necessary that you have defined your domain in script before.**
**Also you need to open following ports in your router configuration: `80/TCP` (Letsencrypt-Auth)**

1. `sudo nano config.sh` and set your domain
2. `sudo ./hornet-installer.sh` and run the script
3. Choose the option "12"
4. Enter your e-mail address for notifications from LetsEncrypt
5. Agree the terms with `A`
6. Choose `N` next
7. Select `1` for installing the certificate

**If you want to reach your node from an external IP (outside of your local network) you need to open the TCP port which is selected in the installer script (trinityport).**
**Also if you want to reach you dashboard from an external IP (outside of your local network) you need to open the TCP port which is selected in the installer script (dashport).**


# Tangle Bay Pool #

**I would be very happy if you would join the Tangle Bay Dock so that together we can provide a strong and reliable node to the ecosystem and thus the Trinity users.**

**To add your node to the dock please follow these steps:**
1. `sudo nano config.sh` and set your node name and pow option
2. `sudo ./hornet-installer.sh` and run the script
3. Choose the option "8"
4. You get now a password! Please copy the password and save it in the config.sh (and also write it down!).
5. You're done, welcome to the dock party!

**To remove your node from the dock please follow these steps:**
1. `sudo nano config.sh` and set your password
2. `sudo ./hornet-installer.sh` and run the script
3. Choose the "9" option
4. If your node details shows up, your node was successfully removed.
5. Thank you very much for your participation in the dock!

**To udpdate your node on the dock please follow these steps:**
1. `sudo nano config.sh` and set your donation address and make sure you have your password set
2. `sudo ./hornet-installer.sh` and run the script
3. Choose the option "10"
4. If your node details shows up, your node was successfully updated.
5. Thank you very much for your participation in the dock!