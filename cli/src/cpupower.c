#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <dirent.h>
#include "cpupower.h"
#include "util.h"

#ifndef NDEBUG
#define CPUFREQ_PATH                    "/home/luca/Scrivania/PowerCenter/mockFiles/cpufreq/"
#define SCALING_MAX_FREQ                "/scaling_max_freq"
#define SCALING_MIN_FREQ                "/scaling_min_freq"
#define SCALING_GOVERNOR                "/scaling_governor"
#define CPUINFO_MAX_FREQ                "/cpuinfo_max_freq"
#define CPUINFO_MIN_FREQ                "/cpuinfo_min_freq"
#define SCALING_AVAILABLE_GOVERNORS     "/scaling_available_governors"
#define ENERGY_PREF                     "/energy_performance_preference"
#define ENERGY_AVAILABLE_PREFS          "/energy_performance_available_preferences"
#define PSTATE_MAX_PERF                 "/home/luca/Scrivania/PowerCenter/mockFiles/intel_pstate/max_perf_pct"
#define PSTATE_MIN_PERF                 "/home/luca/Scrivania/PowerCenter/mockFiles/intel_pstate/min_perf_pct"
#define PSTATE_NO_TURBO                 "/home/luca/Scrivania/PowerCenter/mockFiles/intel_pstate/no_turbo"
#else
#define CPUFREQ_PATH                    "/sys/devices/system/cpu/"
#define SCALING_MAX_FREQ                "/cpufreq/scaling_max_freq"
#define SCALING_MIN_FREQ                "/cpufreq/scaling_min_freq"
#define SCALING_GOVERNOR                "/cpufreq/scaling_governor"
#define CPUINFO_MAX_FREQ                "/cpufreq/cpuinfo_max_freq"
#define CPUINFO_MIN_FREQ                "/cpufreq/cpuinfo_min_freq"
#define SCALING_AVAILABLE_GOVERNORS     "/cpufreq/scaling_available_governors"
#define ENERGY_PREF                     "/cpufreq/energy_performance_preference"
#define ENERGY_AVAILABLE_PREFS          "/cpufreq/energy_performance_available_preferences"
#define PSTATE_MAX_PERF                 "/sys/devices/system/cpu/intel_pstate/max_perf_pct"
#define PSTATE_MIN_PERF                 "/sys/devices/system/cpu/intel_pstate/min_perf_pct"
#define PSTATE_NO_TURBO                 "/sys/devices/system/cpu/intel_pstate/no_turbo"
#endif

int max_freq = -1;
int min_freq = -1;
char *available_governors[32];
char *energy_available_prefs[32];
int governors_size = 0;
int energy_prefs_size = 0;
int cpu_count=0;

void get_cpu_count(){
    DIR * dir = opendir(CPUFREQ_PATH);
    struct dirent * entry;
    while((entry = readdir(dir)) != NULL){
        if(strcmp(entry->d_name, ".") != 0 && strcmp(entry->d_name, "..")){
            cpu_count++;
        }
    }
}

int cpus_read_int(const char *filename){
    char filepath[256];
    sprintf(filepath, "%scpu0%s", CPUFREQ_PATH, filename);
    FILE *file = fopen(filepath,"r");
    char str[256];
    if(fread(str,256,1,file)<0){
        fclose(file);
        return -1;
    }
    int result = parse_int(str);
    fclose(file);
    return result;
}

int read_int(const char *filepath){
    FILE *file = fopen(filepath,"r");
    char str[256];
    if(fread(str,256,1,file)<0){
        fclose(file);
        return -1;
    }
    int result = parse_int(str);
    fclose(file);
    return result;
}

int get_max_available_freq(){
    if(max_freq<0){
        max_freq = cpus_read_int(CPUINFO_MAX_FREQ);
    }
    return max_freq;
}

int get_min_available_freq(){
    if(min_freq<0){
        min_freq = cpus_read_int(CPUINFO_MIN_FREQ);
    }
    return min_freq;
}

char *read_string(const char *filename){
    char filepath[256];
    sprintf(filepath, "%scpu0%s", CPUFREQ_PATH, filename);
    FILE *file = fopen(filepath,"r");
    char *str = malloc(256);
    memset(str,0,256);
    if(fread(str,256,1,file)<0){
        fclose(file);
        return NULL;
    }
    fclose(file);
    return str;
}

int to_str_array(char *str, const char *divider, char **array){
    int size = 0;
    char *element = strtok(str,divider);
    while(element){
        array[size] = element;
        size++;
        element = strtok(NULL,divider);
    }
    return size;
}

void remove_newline_if_present(char *str){
    int str_len = strlen(str);
    if(str[str_len-1]=='\n'){
        str[str_len-1]=0;
    }
}

char **get_available_governors(){
    if(governors_size==0){
        char *all_governors = read_string(SCALING_AVAILABLE_GOVERNORS);
        remove_newline_if_present(all_governors);
        governors_size = to_str_array(all_governors," ", available_governors);
    }
    return available_governors;
}

char **get_energy_available_prefs(){
    if(energy_prefs_size==0){
        char *all_prefs = read_string(ENERGY_AVAILABLE_PREFS);
        remove_newline_if_present(all_prefs);
        energy_prefs_size = to_str_array(all_prefs," ", energy_available_prefs);
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

int cpus_write_int(const char *filename, int val){
    FILE *file;
    char filepath[256];
    for(int i=0;i<cpu_count;i++){
        memset(filepath, 0, 256);
        sprintf(filepath, "%scpu%d%s", CPUFREQ_PATH, i, filename);
        file = fopen(filepath,"w");
        if(!file) return 1;
        fprintf(file,"%d\n",val);
        fclose(file);
    }
    return 0;
}

int cpus_write_string(const char *filename, const char *val){
    FILE *file;
    char filepath[256];
    for(int i=0;i<cpu_count;i++){
        memset(filepath, 0, 256);
        sprintf(filepath, "%scpu%d%s", CPUFREQ_PATH, i, filename);
        file = fopen(filepath,"w");
        if(!file) return 1;
        fprintf(file,"%s\n",val);
        fclose(file);
    }
    return 0;
}

int set_max_freq(int freq){
    if(freq>get_max_available_freq()){
        errno = EINVAL;
        perror("La frequenza e maggiore della massima consentita");
        return 1;
    }
    return cpus_write_int(SCALING_MAX_FREQ, freq);
}

int set_min_freq(int freq){
    if(freq<get_min_available_freq()){
        errno = EINVAL;
        perror("La frequenza e minore della minima consentita");
        return 1;
    }
    return cpus_write_int(SCALING_MIN_FREQ, freq);
}

int set_min_perf(int perc){
    if(perc<8 || perc>100){
        errno = EINVAL;
        perror("La potenza e fuori dal range 8-100");
        return 1;
    }
    FILE *file = fopen(PSTATE_MIN_PERF,"w");
    fprintf(file,"%d\n",perc);
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
    fprintf(file,"%d\n",perc);
    fclose(file);
    return 0;
}

int set_turbo_enabled(bool value){
    FILE *file = fopen(PSTATE_NO_TURBO,"w");
    fprintf(file,"%d\n",value?0:1);
    fclose(file);
    return 0;
}

int set_scaling_governor(const char *governor){
    if(!is_governor_available(governor)){
        errno = EINVAL;
        perror("Il governor non e tra quelli disponibili");
        return 1;
    }
    return cpus_write_string(SCALING_GOVERNOR, governor);
}

int set_energy_pref(const char *pref){
    if(!is_energy_pref_available(pref)){
        errno = EINVAL;
        perror("la scelta non e tra quelli disponibili");
        return 1;
    }
    return cpus_write_string(ENERGY_PREF, pref);
}

int apply_cpu_profile(Profile_t *profile){
    get_cpu_count();
    int error = 0;
    error |= set_max_freq(profile->cpu_max_freq);
    error |= set_min_freq(profile->cpu_min_freq);
    error |= set_scaling_governor(profile->cpu_governor);
    error |= set_energy_pref(profile->cpu_energy_pref);
    error |= set_max_perf(profile->cpu_max_perf);
    error |= set_min_perf(profile->cpu_min_perf);
    error |= set_turbo_enabled(profile->cpu_turbo_enabled);
    return error;
}

int get_max_freq(){
    return cpus_read_int(SCALING_MAX_FREQ);
}

int get_min_freq(){
    return cpus_read_int(SCALING_MIN_FREQ);
}

int get_min_perf(){
    return read_int(PSTATE_MIN_PERF);
}

int get_max_perf(){
    return read_int(PSTATE_MAX_PERF);
}

int get_turbo_enabled(){
    return !read_int(PSTATE_NO_TURBO);
}

char *get_scaling_governor(){
    char *governor = read_string(SCALING_GOVERNOR);
    remove_newline_if_present(governor);
    return governor;
}

char *get_energy_pref(){
    char *pref = read_string(ENERGY_PREF);
    remove_newline_if_present(pref);
    return pref;
}

int read_cpu_profile(Profile_t *profile){
    profile->cpu_max_freq = get_max_freq();
    profile->cpu_min_freq = get_min_freq();
    profile->cpu_max_perf = get_max_perf();
    profile->cpu_min_perf = get_min_perf();
    profile->cpu_turbo_enabled = get_turbo_enabled();
    profile->cpu_governor = get_scaling_governor();
    profile->cpu_energy_pref = get_energy_pref();
    return 0;
}