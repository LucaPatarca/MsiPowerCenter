#ifndef __POWER_CENTER_LIB__
#define __POWER_CENTER_LIB__

#include "profile.h"

int set_profile(const char *path);
Profile_t *read_current_profile();
int write_charging_threshold(unsigned char value);
unsigned char get_charging_threshold();

#endif