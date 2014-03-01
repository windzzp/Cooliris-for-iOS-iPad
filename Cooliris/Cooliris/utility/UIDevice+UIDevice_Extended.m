//
//  UIDevice+UIDevice_Extended.m
//  Cooliris
//
//  Created by user on 13-5-22.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "UIDevice+UIDevice_Extended.h"

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

@implementation UIDevice (UIDevice_Extended)

- (NSString *) macAddress
{
    int arrMac[6] = {
        CTL_NET,
        AF_ROUTE,
        0,
        AF_LINK,
        NET_RT_IFLIST,
        0
    };
    
    arrMac[5] = if_nametoindex("en0");
    if (arrMac[5] == 0) {
        return nil;
    }
    
    size_t len = 0;
    if (sysctl(arrMac, 6, nil, &len, nil, 0) < 0) {
        return nil;
    }
    
    char *buf = malloc(len);
    if (buf == nil) {
        return nil;
    }
    
    if (sysctl(arrMac, 6, buf, &len, nil, 0) < 0) {
        free(buf);
        return nil;
    }
    
    struct if_msghdr *ifm = (struct if_msghdr *)buf;
    struct sockaddr_dl *sdl = (struct sockaddr_dl *)(ifm + 1);
    unsigned char *ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X",
                           *ptr,
                           *(ptr + 1),
                           *(ptr + 2),
                           *(ptr + 3),
                           *(ptr + 4),
                           *(ptr + 5)];
    free(buf);
    
    return outstring;
}
@end
