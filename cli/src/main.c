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
    printf("Usage:\n\tpowercenter [normal|quiet]\n");
}

int main(int argc, char **argv){
    int battery_carging_threshold = -1, opt = 0;

	char *endptr = NULL, *profile = NULL;

	//parsing degli argomenti con il trattino
	while ((opt = getopt(argc, argv, "b:")) != -1)
		switch (opt)
		{
		case 'b':
			battery_carging_threshold = strtol(optarg, &endptr, 10);
			if ((errno != 0 && battery_carging_threshold == 0) || endptr == optarg || *endptr != 0)
				battery_carging_threshold = -1;
			endptr = NULL;
			break;
		case '?':
			printf("argomenti errati\n");
			return 1;
		default:
			return 1;
		}

	//controllo se c'è un profilo da impostare
	if (argc == optind+1)
	{
		profile = argv[optind];
        if(strcmp(profile,"quiet") == 0){
            Profile_t *profile = open_profile(PROF_QUIET);
            apply_ec_profile(profile);
			apply_cpu_profile(profile);
			free_profile(profile);
        } else if(strcmp(profile,"normal") == 0){
            Profile_t *profile = open_profile(PROF_NORMAL);
            apply_ec_profile(profile);
			apply_cpu_profile(profile);
			free_profile(profile);
        } else{
            print_usage();
            return 1;
        }
	}

    if(battery_carging_threshold>30){
        open_ec();
        set_charging_threshold(battery_carging_threshold);
        close_ec();
    }

    return 0;
}