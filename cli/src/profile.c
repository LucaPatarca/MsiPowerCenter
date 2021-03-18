#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <glib-2.0/glib.h>
#include "profile.h"

#define GROUP_GENERAL "General"
#define GROUP_TEMPERATURE "Temperature"
#define GROUP_FAN "Fan"
#define GROUP_POWER "Power"

#define KEY_CPU_TEMPS "CpuTemps"
#define KEY_GPU_TEMPS "GpuTemps"
#define KEY_CPU_FAN_SPEEDS "CpuFanSpeeds"
#define KEY_GPU_FAN_SPEEDS "GpuFanSpeeds"
#define KEY_COOLER_BOOST "CoolerBoost"
#define KEY_CPU_MAX_FREQ "CpuMaxFreq"
#define KEY_CPU_MIN_FREQ "CpuMinFreq"
#define KEY_CPU_SCALING_GOVERNOR "CpuScalingGovernor"
#define KEY_CPU_ENERGY_PREFERENCE "CpuEnergyPreference"
#define KEY_CPU_TURBO_ENABLED "CpuTurboEnabled"
#define KEY_CPU_MAX_PERF "CpuMaxPerf"
#define KEY_CPU_MIN_PERF "CpuMinPerf"

unsigned char * read_value_list(GKeyFile *file, const char *group, const char *key){
    gsize length;
    GError *error = NULL;
    gint *values = g_key_file_get_integer_list(file,group,key,&length,&error);
    if(error){
        printf("%s\n",error->message);
        return NULL;
    }
    if(length!=7){
        printf("Error in %s values, expected 7 was %d", key, length);
        return NULL;
    }
    unsigned char* byte_values = malloc(length);
    for(int i=0;i<length;i++){
        byte_values[i]=values[i] & 0xFF;
    }
    free(values);
    return byte_values;
}

char *read_config_string(GKeyFile *file, const char *group, const char *key){
    gsize length;
    GError *error = NULL;
    char *string = g_key_file_get_string(file,group,key,&error);
    if(error){
        printf("%s\n",error->message);
        return NULL;
    }
    return string;
}

int read_config_int(GKeyFile *file, const char *group, const char *key){
    gsize length;
    GError *error = NULL;
    int value = g_key_file_get_integer(file,group,key,&error);
    if(error){
        printf("%s\n",error->message);
        return -1;
    }
    return value;
}

int read_cpu_temps(Profile_t *profile, GKeyFile *file){
    profile->cpu_temps = read_value_list(file,GROUP_TEMPERATURE,KEY_CPU_TEMPS);
    if(profile->cpu_temps)
        return 0;
    else
        return 1;
}

int read_gpu_temps(Profile_t *profile, GKeyFile *file){
    profile->gpu_temps = read_value_list(file,GROUP_TEMPERATURE,KEY_GPU_TEMPS);
    if(profile->gpu_temps)
        return 0;
    else
        return 1;
}

int read_cpu_fan_speeds(Profile_t *profile, GKeyFile *file){
    profile->cpu_speeds = read_value_list(file,GROUP_FAN,KEY_CPU_FAN_SPEEDS);
    if(profile->cpu_speeds)
        return 0;
    else
        return 1;
}

int read_gpu_fan_speeds(Profile_t *profile, GKeyFile *file){
    profile->gpu_speeds = read_value_list(file,GROUP_FAN,KEY_GPU_FAN_SPEEDS);
    if(profile->gpu_speeds)
        return 0;
    else
        return 1;
}

int read_cooler_boost(Profile_t *profile, GKeyFile *file){
    GError *error = NULL;
    gboolean result = g_key_file_get_boolean(file,GROUP_FAN,KEY_COOLER_BOOST,&error);
    if(error){
        printf("%s\n",error->message);
        return 1;
    }
    profile->cooler_boost_enabled = result;
    return 0;
}

int read_cpu_max_freq(Profile_t *profile, GKeyFile *file){
    profile->cpu_max_freq = read_config_int(file,GROUP_POWER,KEY_CPU_MAX_FREQ);
    return profile->cpu_max_freq<0;
}

int read_cpu_min_freq(Profile_t *profile, GKeyFile *file){
    profile->cpu_min_freq = read_config_int(file,GROUP_POWER,KEY_CPU_MIN_FREQ);
    return profile->cpu_min_freq<0;
}

int read_cpu_min_perf(Profile_t *profile, GKeyFile *file){
    profile->cpu_min_perf = read_config_int(file,GROUP_POWER,KEY_CPU_MIN_PERF);
    return profile->cpu_min_perf<0;
}

int read_cpu_max_perf(Profile_t *profile, GKeyFile *file){
    profile->cpu_max_perf = read_config_int(file,GROUP_POWER,KEY_CPU_MAX_PERF);
    return profile->cpu_max_perf<0;
}

int read_cpu_turbo_enabled(Profile_t *profile, GKeyFile *file){
    GError *error = NULL;
    gboolean result = g_key_file_get_boolean(file,GROUP_POWER,KEY_CPU_TURBO_ENABLED,&error);
    if(error){
        printf("%s\n",error->message);
        return 1;
    }
    profile->cpu_turbo_enabled = result;
    return 0;
}

int read_cpu_scaling_governor(Profile_t *profile, GKeyFile *file){
    profile->cpu_governor = read_config_string(file,GROUP_POWER,KEY_CPU_SCALING_GOVERNOR);
    if(profile->cpu_governor)
        return 0;
    else
        return 1;
}

int read_cpu_energy_pref(Profile_t *profile, GKeyFile *file){
    profile->cpu_energy_pref = read_config_string(file,GROUP_POWER,KEY_CPU_ENERGY_PREFERENCE);
    if(profile->cpu_energy_pref)
        return 0;
    else
        return 1;
}

Profile_t *open_profile(const char *filename){
    Profile_t *profile = malloc(sizeof(Profile_t));
    GKeyFile *file = g_key_file_new();
    GError *gerror;
    g_key_file_load_from_file(file,filename,G_KEY_FILE_NONE,&gerror);
    if(gerror){
        perror(filename);
        return NULL;
    }
    int error = 0;
    error |= read_cpu_temps(profile,file);
    error |= read_gpu_temps(profile,file);
    error |= read_cpu_fan_speeds(profile,file);
    error |= read_gpu_fan_speeds(profile,file);
    error |= read_cooler_boost(profile,file);
    error |= read_cpu_max_freq(profile,file);
    error |= read_cpu_min_freq(profile,file);
    error |= read_cpu_scaling_governor(profile,file);
    error |= read_cpu_energy_pref(profile,file);
    error |= read_cpu_max_perf(profile,file);
    error |= read_cpu_min_perf(profile,file);
    error |= read_cpu_turbo_enabled(profile,file);
    g_key_file_free(file);
    if(error){
        free_profile(profile);
        return NULL;
    }
    else
        return profile;
}

void free_profile(Profile_t *profile){
    free(profile->cpu_temps);
    free(profile->gpu_temps);
    free(profile->cpu_speeds);
    free(profile->gpu_speeds);
    free(profile);
}