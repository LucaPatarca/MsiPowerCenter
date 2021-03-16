#ifndef __POWER_CENTER_EC__
#define __POWER_CENTER_EC__

#include "profile.h"

//TODO rimuovere
int apply_ec_profile(Profile_t *profile);

int open_ec();

int close_ec();

int set_cpu_temps(unsigned char *temps);

int set_gpu_temps(unsigned char *temps);

int set_cpu_fan_speeds(unsigned char *speeds);

int set_gpu_fan_speeds(unsigned char *speeds);

int set_cooler_boost_on();

int set_cooler_boost_off();

int set_charging_threshold(unsigned char threshold);

#endif