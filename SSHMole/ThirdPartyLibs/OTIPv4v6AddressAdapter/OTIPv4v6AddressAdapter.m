//
//  OTIPv4v6AddressConverter.m
//  OTIPv4v6AddressConverterDemo
//
//  Created by openthread on 6/21/16.
//  Copyright © 2016 openthread. All rights reserved.
//

#import "OTIPv4v6AddressAdapter.h"
#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <err.h>

@implementation OTIPv4v6AddressAdapter

+ (nullable NSString *)adaptedAddressForOriginalIPAddress:(NSString *)originalAddress
{
    struct addrinfo hints, *res, *res0;
    int error;
    const char *address = [originalAddress cStringUsingEncoding:NSUTF8StringEncoding];
    
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = PF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_flags = AI_DEFAULT;
    error = getaddrinfo(address, NULL, &hints, &res0);
    if (error)
    {
        NSString *errorString = [[NSString alloc] initWithCString:gai_strerror(error) encoding:NSUTF8StringEncoding];
        NSLog(@"getaddrinfo failed : %@", errorString);
        return nil;
    }
    
    NSString *result = nil;
    for (res = res0; res; res = res->ai_next)
    {
        struct sockaddr *addr = (struct sockaddr *)res->ai_addr;
        NSString *ipString = [self getSockAddrIPString:addr];
        if (ipString.length != 0)
        {
            result = ipString;
        }
    }
    freeaddrinfo(res0);
    return result;
}

+ (NSString *)getSockAddrIPString:(const struct sockaddr *)sa
{
    switch(sa->sa_family)
    {
        case AF_INET:
        {
            char ipv4_str_buf[INET_ADDRSTRLEN] = { 0 };
            struct sockaddr_in *v4sa = (struct sockaddr_in *)sa;
            inet_ntop(AF_INET, &(v4sa->sin_addr),
                      ipv4_str_buf, sizeof(ipv4_str_buf));
            NSString *result = [[NSString alloc] initWithCString:ipv4_str_buf encoding:NSUTF8StringEncoding];
            return result;
        }
            break;
        case AF_INET6:
        {
            char ipv6_str_buf[INET6_ADDRSTRLEN] = { 0 };
            struct sockaddr_in6 *v6sa = (struct sockaddr_in6 *)sa;
            inet_ntop(AF_INET6, &(v6sa->sin6_addr),
                      ipv6_str_buf, sizeof(ipv6_str_buf));
            NSString *result = [[NSString alloc] initWithCString:ipv6_str_buf encoding:NSUTF8StringEncoding];
            return result;
        }
            break;
        default:
            return @"";
    }
    return @"";
}

@end
