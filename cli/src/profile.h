#ifndef __POWER_CENTER_PROFILE__
#define __POWER_CENTER_PROFILE__

#define PROF_QUIET "/home/luca/Scrivania/PowerCenter/profiles/quiet.ini"
#define PROF_NORMAL "/home/luca/Scrivania/PowerCenter/profiles/normal.ini"

typedef struct profile{
    unsigned char *cpu_temps;
    unsigned char *gpu_temps;
    unsigned char *cpu_speeds;
    unsigned char *gpu_speeds;
    int cooler_boost_enabled;
    int cpu_max_freq;
    int cpu_min_freq;
    char *cpu_governor;
    char *cpu_energy_pref;
    int cpu_max_perf;
    int cpu_min_perf;
    int cpu_turbo_enabled;
    int charging_threshold;
} Profile_t;

Profile_t *open_profile(const char *filename);

void free_profile(Profile_t *profile);

#endif