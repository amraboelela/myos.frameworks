/*
 Copyright © 2014-2015 myOS Group.
 
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 Lesser General Public License for more details.
 
 Contributor(s):
 Amr Aboelela <amraboelela@gmail.com>
 */

#include "CoreFoundation/CFBase.h"
#include "CoreFoundation/CFRuntime.h"
#include "GSPrivate.h"

#include <stdlib.h>
#include <string.h>

long CFGetFreeMemory()
{
    FILE *fp = fopen("/proc/meminfo", "r");
    if (fp!=NULL) {
        size_t bufsize = 1024 * sizeof(char);
        char *buf = (char *)malloc(bufsize);
        long value = -1L;
        while (getline(&buf, &bufsize, fp) >= 0) {
            if (strncmp(buf, "MemFree", 7) != 0) {
                continue;
            }
            sscanf(buf, "MemFree: %ld", &value);
            break;
        }
        fclose(fp);
        free((void *)buf);
        return value;
    }
    return 0;
}
