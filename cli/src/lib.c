#include "lib.h"
#include "ec.h"
#include "cpupower.h"
#include <stdio.h>
#include <stdlib.h>

int set_profile(const char *path){
    Profile_t *profile = open_profile(path);
	if(!profile){
        perror(path);
		return 1;
	}
    apply_ec_profile(profile);
	apply_cpu_profile(profile);
	free_profile(profile);
    return 0;
}

Profile_t *read_current_profile(){
    Profile_t * profile = empty_profile();
	read_cpu_profile(profile);
	read_ec_profile(profile);
    return profile;
}

int write_charging_threshold(unsigned char value){
    open_ec();
    int res = set_charging_threshold(value);    
    close_ec();
    return res;
}

unsigned char read_charging_threshold(){
    open_ec();
    int value = get_charging_threshold();
    close_ec();
    return value;
}

int set_cooler_boost(int value){
    open_ec();
    if(value){
        set_cooler_boost_on();
    } else{
        set_cooler_boost_off();
    }
    close_ec();
    return 0;
}

int get_cooler_boost(){
    open_ec();
    int res = is_cooler_boost_enabled();
    close_ec();
    return res;
}