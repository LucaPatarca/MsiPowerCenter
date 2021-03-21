#!/bin/bash
[ -f "/etc/modprobe.d/mpc-ec_sys.conf" ] || sudo cp conf/modprobe.d/mpc-ec_sys.conf /etc/modprobe.d/mpc-ec_sys.conf
[ -f "/etc/modules-load.d/mpc-ec_sys.conf" ] || sudo cp conf/modules-load.d/mpc-ec_sys.conf /etc/modules-load.d/mpc-ec_sys.conf
cd gui
flutter build linux --release
cd ../cli
[ -d "build" ] || mkdir build
cmake -S . -B build -DCMAKE_BUILD_TYPE:STRING=Release
cmake --build build --target msictrl -- -j 10
cp build/libmsictrl.so ../gui/build/linux/x64/release/bundle/lib/
[ -d "/opt/MsiPowerCenter" ] && sudo rm -r /opt/MsiPowerCenter
sudo cp -r ../gui/build/linux/x64/release/bundle /opt/MsiPowerCenter
sudo cp -r ../profiles /opt/MsiPowerCenter/profiles
cp ../conf/msipowercenter.desktop /home/$USER/.local/share/applications/msipowercenter.desktop
sudo cp ../conf/org.freedesktop.policykit.pkexec.policy /usr/share/polkit-1/actions/org.freedesktop.policykit.pkexec.policy 
