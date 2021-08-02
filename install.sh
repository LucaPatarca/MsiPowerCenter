#!/bin/bash
[ -d "/opt/MsiPowerCenter" ] && sudo rm -r /opt/MsiPowerCenter

[ -f "/etc/modprobe.d/mpc-ec_sys.conf" ] || sudo cp conf/modprobe.d/mpc-ec_sys.conf /etc/modprobe.d/mpc-ec_sys.conf
[ -f "/etc/modules-load.d/mpc-ec_sys.conf" ] || sudo cp conf/modules-load.d/mpc-ec_sys.conf /etc/modules-load.d/mpc-ec_sys.conf

cd gui
flutter build linux --release
sudo cp -r build/linux/x64/release/bundle /opt/MsiPowerCenter/

cd ../cli
[ -d "build" ] || mkdir build
cmake -S . -B build -DCMAKE_BUILD_TYPE:STRING=Release
cmake --build build --target backend -- -j 10
sudo cp build/backend /opt/MsiPowerCenter/

cd ..
sudo cp -r icon.png /opt/MsiPowerCenter/
sudo cp -r profiles /opt/MsiPowerCenter/profiles
[ -d "/opt/MsiPowerCenter/pipes" ] || sudo mkdir /opt/MsiPowerCenter/pipes
sudo cp conf/msipowercenter.service /etc/systemd/system/
sudo systemctl enable msipowercenter.service --now
cp conf/msipowercenter.desktop /home/$USER/.local/share/applications/msipowercenter.desktop
