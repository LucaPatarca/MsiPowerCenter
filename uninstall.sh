#!/bin/bash

rm /home/$USER/.local/share/applications/msipowercenter.desktop

sudo systemctl disable msipowercenter.service --now
sudo rm /etc/systemd/system/msipowercenter.service

sudo rm /etc/modprobe.d/mpc-ec_sys.conf
sudo rm /etc/modules-load.d/mpc-ec_sys.conf

sudo rm -r /opt/MsiPowerCenter

echo "MsiPowerCenter uninstalled sucessfully"
echo "You should reboot your computer"
