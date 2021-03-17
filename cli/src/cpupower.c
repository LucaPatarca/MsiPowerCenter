#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "cpupower.h"

#define SCALING_MAX_FREQ                "/sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq"
#define SCALING_MIN_FREQ                "/sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq"
#define SCALING_GOVERNOR                "/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
#define CPUINFO_MAX_FREQ                "/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq"
#define CPUINFO_MIN_FREQ                "/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq"
#define SCALING_AVAILABLE_GOVERNORS     "/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors"
#define ENERGY_PREF                     "/sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference"
#define ENERGY_AVAILABLE_PREFS          "/sys/devices/system/cpu/cpu0/cpufreq/energy_performance_available_preferences"
#define PSTATE_MAX_PERF                 "/sys/devices/system/cpu/intel_pstate/max_perf_pct"
#define PSTATE_MIN_PERF                 "/sys/devices/system/cpu/intel_pstate/min_perf_pct"
#define PSTATE_NO_TURBO                 "/sys/devices/system/cpu/intel_pstate/no_turbo"

int max_freq = -1;
int min_freq = -1;
char *available_governors[32];
char *energy_available_prefs[32];
int governors_size = 0;
int energy_prefs_size = 0;

int get_max_freq(){
    if(max_freq<0){
        FILE *file = fopen(CPUINFO_MAX_FREQ,"r");
        char max_freq_str[64];
        fread(max_freq_str,32,1,file);
        char *endptr;
        max_freq = strtol(max_freq_str,&endptr,10);
        if ((errno != 0 && max_freq == 0)){
            max_freq = -1;
        }
    }
    return max_freq;
}

int get_min_freq(){
    if(min_freq<0){
        FILE *file = fopen(CPUINFO_MIN_FREQ,"r");
        char min_freq_str[64];
        fread(min_freq_str,32,1,file);
        char *endptr;
        min_freq = strtol(min_freq_str,&endptr,10);
        if ((errno != 0 && min_freq == 0)){
            min_freq = -1;
        }
        fclose(file);
    }
    return min_freq;
}

char **get_available_governors(){
    if(governors_size==0){
        FILE *file = fopen(SCALING_AVAILABLE_GOVERNORS,"r");
        char all_governors[256];
        if(fread(all_governors,256,1,file)<0){
            return NULL;
        }
        int all_governors_strlen = strlen(all_governors);
        if(all_governors[all_governors_strlen-1]=='\n'){
            all_governors[all_governors_strlen-1]=0;
        }
        char *governor = strtok(all_governors," ");
        while(governor){
            available_governors[governors_size] = governor;
            governors_size++;
            governor = strtok(NULL," ");
        }
        fclose(file);
    }
    return available_governors;
}

char **get_energy_available_prefs(){
    if(energy_prefs_size==0){
        FILE *file = fopen(ENERGY_AVAILABLE_PREFS,"r");
        char all_prefs[256];
        if(fread(all_prefs,256,1,file)<0){
            return NULL;
        }
        int all_prefs_strlen = strlen(all_prefs);
        if(all_prefs[all_prefs_strlen-1]=='\n'){
            all_prefs[all_prefs_strlen-1]=0;
        }
        char *pref = strtok(all_prefs," ");
        while(pref){
            energy_available_prefs[energy_prefs_size] = pref;
            energy_prefs_size++;
            pref = strtok(NULL," ");
        }
        fclose(file);
    }
    return energy_available_prefs;
}

int is_governor_available(const char *governor){
    char **governors = get_available_governors();
    for(int i=0;i<governors_size;i++){
        if(strcmp(governors[i],governor)==0)
            return 1;
    }
    return 0;
}

int is_energy_pref_available(const char *pref){
    char **prefs = get_energy_available_prefs();
    for(int i=0;i<energy_prefs_size;i++){
        if(strcmp(prefs[i],pref)==0)
            return 1;
    }
    return 0;
}

int set_max_freq(int freq){
    if(freq>get_max_freq()){
        errno = EINVAL;
        perror("La frequenza e maggiore della massima consentita");
        return 1;
    }
    FILE *file = fopen(SCALING_MAX_FREQ,"w");
    fprintf(file,"%d",freq);
    fclose(file);
    return 0;
}

int set_min_freq(int freq){
    if(freq<get_min_freq()){
        errno = EINVAL;
        perror("La frequenza e minore della minima consentita");
        return 1;
    }
    FILE *file = fopen(SCALING_MIN_FREQ,"w");
    fprintf(file,"%d",freq);
    fclose(file);
    return 0;
}

int set_min_perf(int perc){
    if(perc<8 || perc>100){
        errno = EINVAL;
        perror("La potenza e fuori dal range 8-100");
        return 1;
    }
    FILE *file = fopen(PSTATE_MIN_PERF,"w");
    fprintf(file,"%d",perc);
    fclose(file);
    return 0;
}

int set_max_perf(int perc){
    if(perc<8 || perc>100){
        errno = EINVAL;
        perror("La potenza e fuori dal range 8-100");
        return 1;
    }
    FILE *file = fopen(PSTATE_MAX_PERF,"w");
    fprintf(file,"%d",perc);
    fclose(file);
    return 0;
}

int set_no_turbo(bool value){
    FILE *file = fopen(PSTATE_NO_TURBO,"w");
    fprintf(file,"%d",value?1:0);
    fclose(file);
    return 0;
}

int set_scaling_governor(const char *governor){
    if(!is_governor_available(governor)){
        errno = EINVAL;
        perror("Il governor non e tra quelli disponibili");
        return 1;
    }
    FILE *file = fopen(SCALING_GOVERNOR,"w");
    fprintf(file,"%s",governor);
    fclose(file);
    return 0;
}

int set_energy_pref(const char *pref){
    if(!is_energy_pref_available(pref)){
        errno = EINVAL;
        perror("la scelta non e tra quelli disponibili");
        return 1;
    }
    FILE *file = fopen(ENERGY_PREF,"w");
    fprintf(file,"%s",pref);
    fclose(file);
    return 0;
}

int apply_cpu_profile(Profile_t *profile){
    int error = 0;
    error |= set_max_freq(profile->cpu_max_freq);
    error |= set_min_freq(profile->cpu_min_freq);
    error |= set_scaling_governor(profile->cpu_governor);
    error |= set_energy_pref(profile->cpu_energy_pref);
    error |= set_max_perf(profile->cpu_max_perf);
    error |= set_min_perf(profile->cpu_min_perf);
    error |= set_no_turbo(profile->cpu_no_turbo);
    return error;
}