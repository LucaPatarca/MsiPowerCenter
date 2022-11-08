# MsiPowerCenter
### :warning: **WARNING!** Use it at your own risk!

![MsiPowerCenter app light mode](/docs/light.png?raw=true "MsiPowerCenter app light mode")
![MsiPowerCenter app dark mode](/docs/dark.png?raw=true "MsiPowerCenter app dark mode")

### Description
MsiPowerCenter is a **Linux** application to manage the fan speed, power consumption and performance of my MSI Prestige 15 a11scx laptop. The idea comes from the official app **MSI Center for Business & Productivity** which only runs on Windows. 

### Credits
I used this [document](https://github.com/YoyPa/isw/blob/master/wiki/msi%20ec.pdf) to understand how the EC (Embedded Controller) works for Msi laptops.

### Brief explanation
- **backend** : contains the Rust source code to build the backend which should be started by the systemd service contained in the conf directory.
- **conf** : contains all the configuration files needed to install the app
- **gui** : is the frontend code made using flutter.
- **mockFiles** : are a list of fake system files used by the backend when compiled in Debug mode, this is necessary because the real files require root permission and debugging would be a problem.
- **profiles** : contains the cofiguration of the default profiles

### Why frontend/backend?
The system files that this program manipulates require root permission (some even for reading), so in order to write them you need to run with root permission. This means that every time you open the app you must enter the root password. To overcome this issue i implemented a rust backend which is started by a systemd service with root permissions. The backend accepts command as input (for intance: apply the balanced profile and give me back the result) and then performs the low level operation. This means that now the frontend can run at user level.

### How to install
At the moment in order to compile the app you need to have a complete flutter and rust toolchain installed on your system.
Then you can just run the install.sh script and give it the root possword when required.

### These are some of the features that i plan to implement:
- [ ] Simplify installation instruction/procedure
- [ ] Replace the entire backend service with a linux kernel module
- [ ] Make it more general so that it can work on different MSI computers
- [ ] Write a basic cli tool for automations and stuff
- [x] Add more and better profiles (at least 4 like the windows software)
- [ ] User will be able to create fully customized profiles (using the GUI app)
