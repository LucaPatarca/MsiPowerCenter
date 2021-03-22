#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include "profile.h"
#include "ec.h"
#include "cpupower.h"

extern char *optarg;
extern int optind;

void print_usage(){
    printf("Usage:\n\tpowercenter [-r] [-p profile-path] [-b battery-level]\n");
}

void print_current_profile(){
	Profile_t * profile = empty_profile();
	read_cpu_profile(profile);
	read_ec_profile(profile);

	printf("max frequency: %dHz\nmin freqquency: %dHz\nmax performance: %d%%\nmin performance: %d%%\ngovernor: %s\nenergy preference: %s\nturbo: %s\n",
		profile->cpu_max_freq,profile->cpu_min_freq,profile->cpu_max_perf,profile->cpu_min_perf,profile->cpu_governor,profile->cpu_energy_pref,
		profile->cooler_boost_enabled?"enabled":"disabled");
	printf("cpu temperatures: ");
	for(int i=0; i<7;i++)
		printf("%d ",profile->cpu_temps[i]);
	printf("\n");
	printf("gpu temperatures: ");
	for(int i=0; i<7;i++)
		printf("%d ",profile->gpu_temps[i]);
	printf("\n");
	printf("cpu fan speeds: ");
	for(int i=0; i<7;i++)
		printf("%d ",profile->cpu_speeds[i]);
	printf("\n");
	printf("gpu fan speeds: ");
	for(int i=0; i<7;i++)
		printf("%d ",profile->gpu_speeds[i]);
	printf("\n");
	printf("cooler boost: %s\n",profile->cooler_boost_enabled?"enabled":"disabled");

	free_profile(profile);
}

int main(int argc, char **argv){
    int battery_carging_threshold = -1, opt = 0, read = 0;

	char *endptr = NULL, *profile_path = NULL;

	while ((opt = getopt(argc, argv, "p:rb:")) != -1)
		switch (opt)
		{
		case 'b':
			battery_carging_threshold = strtol(optarg, &endptr, 10);
			if ((errno != 0 && battery_carging_threshold == 0) || endptr == optarg || *endptr != 0)
				battery_carging_threshold = -1;
			endptr = NULL;
			break;
		case 'p':
			profile_path = optarg;
			break;
		case 'r':
			read = 1;
			break;
		case '?':
			printf("wrong arguments\n");
			return 1;
		default:
			return 1;
		}

	if(argc > optind || (!profile_path && !read && battery_carging_threshold<30)){
		print_usage();
		return 1;
	}

	//controllo se c'è un profilo da impostare
	if (profile_path)
	{
        Profile_t *profile = open_profile(profile_path);
		if(!profile){
			return 1;
		}
        apply_ec_profile(profile);
		apply_cpu_profile(profile);
		printf("Applied profile: %s\n",profile->name);
		free_profile(profile);
	}

	if(read){
		print_current_profile();
	}

    if(battery_carging_threshold>=30){
        open_ec();
        set_charging_threshold(battery_carging_threshold);
        close_ec();
    }
}