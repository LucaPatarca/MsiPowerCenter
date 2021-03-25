# MsiPowerCenter
### :warning: **WARNING!** this project is in an early state, it may not work at all on computers other than mine. In any case, even in its final state it will probably just work on MSI laptops at best. Use it at your own risk!

### Description
This project is my best try on making a **Linux** application to manage the fan speed, power consumption and performance on my MSI Prestige 15 a11scx laptop. The idea comes from the official app **MSI Center for Business & Productivity** which only runs on Windows (thanks MSI). 

#### Credits
I wouldn't have even started if i didn't find this repo: https://github.com/YoyPa/isw where i found this super useful [document](https://github.com/YoyPa/isw/blob/master/wiki/msi%20ec.pdf) that explains how the EC (Embedded Controller) on MSI laptops works. 

#### Brief explanation
- **cli** : contains the c source code and cmake files to build the c executable and the c library.
- **conf** : contains all the configuration files needed to install the app
- **gui** : is a flutter application that uses the c dynamic library to perform all the low level operations.
- **mockFiles** : are a list of fake system files used by the c program if compiled in Debug mode, this is necessary because the real files require root permission and debugging would be a problem.
- **profiles** : contains the cofiguration of the default profiles

#### How to install
At the moment you need to have flutter installed on your system, you also need cmake, make, a c compiler and the glib library.
Then you can just run the install.sh script and give it the root possword when required.

#### These are some of the features that i plan to implement:
- [ ] Make it more general so that it can work on different MSI computers
- [ ] Make it easier to build for other people
- [ ] Add more and better profiles (at least 4 like the windows software)
- [ ] A more useful GUI application to visualize current profile information
- [ ] User should be able to create fully customized profiles (using the GUI app)
