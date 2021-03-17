#ifndef __POWER_CENTER_CPUPOWER__
#define __POWER_CENTER_CPUPOWER__

#include "profile.h"
#include <stdbool.h>

int apply_cpu_profile(Profile_t *profile);

int get_max_freq();

int get_min_freq();

char **get_available_governors();

char **get_energy_available_prefs();

int set_max_freq(int freq);

int set_min_freq(int freq);

int set_min_perf(int perc);

int set_max_perf(int perc);

int set_no_turbo(bool value);

int set_scaling_governor(const char *governor);

int set_energy_pref(const char *pref);



#endif