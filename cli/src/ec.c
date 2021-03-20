#include <stdio.h>
#include <stdlib.h>
#include "ec.h"
#include "profile.h"
#ifndef NDEBUG
#define EC_PATH "/home/luca/Scrivania/PowerCenter/mockFiles/io"
#else
#define EC_PATH "/sys/kernel/debug/ec/ec0/io"
#endif

#define CPU_TEMP_START              0x6A
#define CPU_TEMP_END                0x70
#define GPU_TEMP_START              0x82
#define GPU_TEMP_END                0x88
#define REALTIME_CPU_TEMP           0x68
#define REALTIME_GPU_TEMP           0x80
#define CPU_FAN_START               0x72
#define CPU_FAN_END                 0x78
#define GPU_FAN_START               0x8A
#define GPU_FAN_END                 0x90
#define REALTIME_CPU_FAN_SPEED      0x71
#define REALTIME_GPU_FAN_SPEED      0x89
#define COOLER_BOOST_ADDR           0x98
#define CHARGING_THRESHOLD_ADDR     0xEF
#define FAN_MODE_ADDR               0xF4
#define COOLER_BOOST_ON             0x80
#define COOLER_BOOST_OFF            0x00

FILE *ec = NULL;

int open_ec(){
    ec = fopen(EC_PATH,"rb+");
    return ec != NULL;
}

int close_ec(){
    fclose(ec);
}

int write_ec(int address, unsigned char *values, int count){
    fseek(ec,address,SEEK_SET);
    fwrite(values,1,count,ec);
}

int apply_ec_profile(Profile_t *profile){
    open_ec();
    set_cpu_temps(profile->cpu_temps);
    set_gpu_temps(profile->gpu_temps);
    set_cpu_fan_speeds(profile->cpu_speeds);
    set_gpu_fan_speeds(profile->gpu_speeds);
    if(profile->cooler_boost_enabled){
        set_cooler_boost_on();
    }else{
        set_cooler_boost_off();
    }
    close_ec();
    return 0;
}

int set_cpu_temps(unsigned char *temps){
    write_ec(CPU_TEMP_START,temps,7);
}

int set_gpu_temps(unsigned char *temps){
    write_ec(GPU_TEMP_START,temps,7);
}

int set_cpu_fan_speeds(unsigned char *speeds){
    write_ec(CPU_FAN_START,speeds,7);
}

int set_gpu_fan_speeds(unsigned char *speeds){
    write_ec(GPU_FAN_START,speeds,7);
}

int set_cooler_boost_on(){
    unsigned char value = COOLER_BOOST_ON;
    write_ec(COOLER_BOOST_ADDR,&value,1);
}

int set_cooler_boost_off(){
    unsigned char value = COOLER_BOOST_OFF;
    write_ec(COOLER_BOOST_ADDR,&value,1);
}

int set_charging_threshold(unsigned char threshold){
    unsigned char formatted_threshold = threshold+0x80;
    write_ec(CHARGING_THRESHOLD_ADDR,&formatted_threshold,1);
    return 0;
}

unsigned char read_ec_value(int address){
    if(fseek(ec,address,SEEK_SET)!=0){
        perror("seek error");
        return -1;
    }
    unsigned char result = 1;
    if(fread(&result,1,1,ec)<=0){
        perror("ec_read");
        return -1;
    }
    return result;
}

unsigned char *read_ec_value_array(int start, int end){
    unsigned char *array = malloc((end-start+1)*sizeof(unsigned char));
    for(int i=start;i<=end;i++){
        array[i-start] = read_ec_value(i);
    }
    return array;
}

unsigned char *get_cpu_temps(){
    return read_ec_value_array(CPU_TEMP_START, CPU_TEMP_END);
}

unsigned char *get_gpu_temps(){
    return read_ec_value_array(GPU_TEMP_START, GPU_TEMP_END);
}

unsigned char *get_cpu_fan_speeds(){
    return read_ec_value_array(CPU_FAN_START, CPU_FAN_END);
}

unsigned char *get_gpu_fan_speeds(){
    return read_ec_value_array(GPU_FAN_START, GPU_FAN_END);
}

unsigned char is_cooler_boost_enabled(){
    return read_ec_value(COOLER_BOOST_ADDR)>=COOLER_BOOST_ON;
}

unsigned char get_charging_threshold(){
    return read_ec_value(CHARGING_THRESHOLD_ADDR)-0x80;
}

int read_ec_profile(Profile_t *profile){
    open_ec();
    profile->cpu_temps = get_cpu_temps();
    profile->gpu_temps = get_gpu_temps();
    profile->cpu_speeds = get_cpu_fan_speeds();
    profile->gpu_speeds = get_gpu_fan_speeds();
    profile->cooler_boost_enabled = is_cooler_boost_enabled();
    close_ec();
    return 0;
}