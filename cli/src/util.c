#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include "util.h"

int parse_int(const char *str){
    int result;
    result = strtol(str,NULL,10);
    if ((errno != 0 && result == 0)){
        perror(str);
        result = -1;
    }
    return result;
}