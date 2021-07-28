#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>
#include "profile.h"
#include "ec.h"
#include "cpupower.h"

#define QUIT 0
#define GET 1
#define SET 2
#define PERFORMANCE 3
#define BALANCED 4
#define SILENCE 5
#define BATTERY 6
#define COOLER_BOOST 7
#define CHARGING_LIMIT 8
#define PROFILE 9

extern char *optarg;
extern int optind;

int fdInput;
int fdOutput;

void print_usage(){
    printf("Usage:\n\tpowercenter [-r] [-p profile-path] [-b battery-level]\n");
}

void print_current_profile_json(){
	Profile_t * profile = empty_profile();
	read_cpu_profile(profile);
	int x = read_ec_profile(profile);
	if(x != 0){
		perror("ERROR reading profile: ");
		free_profile(profile);
		return;
	}

	char result[1024];
	memset(result,0,1024);
	char temp[256];

	sprintf(temp, "{\"maxFrequency\": %d,\"minFrequency\": %d,\"maxPerformance\": %d,\"minPerformance\": %d, \"governor\": \"%s\", \"energyPreference\": \"%s\", \"turbo\": %s, ",
		profile->cpu_max_freq,profile->cpu_min_freq,profile->cpu_max_perf,profile->cpu_min_perf,profile->cpu_governor,profile->cpu_energy_pref,
		profile->cpu_turbo_enabled?"true":"false");
	strcat(result,temp);
	sprintf(temp, "\"cpuFanConfig\":[ ");
	strcat(result, temp);
	for(int i=0;i<6;i++){
		sprintf(temp, "{\"temp\": %d, \"speed\": %d}, ", profile->cpu_temps[i],profile->cpu_speeds[i]);
		strcat(result, temp);
	}
	sprintf(temp, "{\"temp\": %d, \"speed\": %d}], ", profile->cpu_temps[6],profile->cpu_speeds[6]);
	strcat(result, temp);
	sprintf(temp, "\"gpuFanConfig\":[ ");
	strcat(result, temp);
	for(int i=0;i<6;i++){
		sprintf(temp, "{\"temp\": %d, \"speed\": %d}, ", profile->gpu_temps[i],profile->gpu_speeds[i]);
		strcat(result, temp);
	}
	sprintf(temp, "{\"temp\": %d, \"speed\": %d}], ", profile->gpu_temps[6],profile->gpu_speeds[6]);
	strcat(result, temp);
	sprintf(temp,"\"coolerBoost\": %s }\n",profile->cooler_boost_enabled?"true":"false");
	strcat(result,temp);

	free_profile(profile);
	write(fdOutput,result,strlen(result));
	printf("profilo scritto\n");
}

int read_next(){
	unsigned char next = 0;
	ssize_t count = read(fdInput,&next,1);
	if(count == 0) return -1;
	printf("ricevuto: %d\n", next);
	return next;
}

int get(int next){
	switch (next){
		case PROFILE:
			print_current_profile_json();
			break;
		case CHARGING_LIMIT:
			int charging_limit = get_charging_threshold();
			printf("charging limit: %d", charging_limit);
			break;
		case COOLER_BOOST:
			unsigned char cooler_boost = is_cooler_boost_enabled();
			printf("cooler boost: %d", cooler_boost);
			break;
		
		default:
			break;
	}
}

void apply_profile(const char * path){
	Profile_t *profile = open_profile(path);
	int result = apply_cpu_profile(profile);
	apply_ec_profile(profile);
	free_profile(profile);
}

void set(int next){
	switch (next){
		case PERFORMANCE:
			apply_profile("/opt/MsiPowerCenter/profiles/performance.ini");
			break;
		case BALANCED:
			apply_profile("/opt/MsiPowerCenter/profiles/balanced.ini");
			break;
		case SILENCE:
			apply_profile("/opt/MsiPowerCenter/profiles/silence.ini");
			break;
		case BATTERY:
			apply_profile("/opt/MsiPowerCenter/profiles/battery.ini");
			break;
		case COOLER_BOOST:
			int cooler_boost = read_next();
			open_ec();
			if(cooler_boost == 0)
				set_cooler_boost_off();
			else
				set_cooler_boost_on();
			close_ec();
			break;
		case CHARGING_LIMIT:
			int charging_limit = read_next();
			open_ec();
			set_charging_threshold(charging_limit);
			close_ec();
			break;
	
		default:
			break;
	}
}

int main(int argc, char **argv){
    const char* inputPipe = "./input";
	mkfifo(inputPipe, 0666);
	const char* outputPipe = "./output";
	mkfifo(outputPipe, 0666);
	fdOutput = open(outputPipe, O_CREAT | O_RDWR);
	fdInput = open(inputPipe, O_CREAT | O_RDWR);
	int exec = true;
	
	while(exec){
		int next = read_next();
		switch (next) {
			case QUIT:
				exec = false;
				break;
			case GET:
				next = read_next();
				get(next);
				break;
			case SET:
				next = read_next();
				set(next);
				break;
			
			default:
				break;
		}
	}

	close(fdInput);
	close(fdOutput);
	unlink(inputPipe);
	unlink(outputPipe);

	return 0;
}