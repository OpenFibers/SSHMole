//
//  SMIPAddressHelper.m
//  SSHMole
//
//  Created by openthread on 7/7/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMIPAddressHelper.h"
#import <ifaddrs.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <net/ethernet.h>
#import <net/if_dl.h>
#import <SystemConfiguration/SystemConfiguration.h>

@implementation SMIPAddressHelper

+ (NSString *)primaryNetworkIPAddress
{
    NSString *ipv4Address = [self primaryNetworkIPv4AddressFromSystemConfiguration];
    if (ipv4Address.length)
    {
        return ipv4Address;
    }
    NSString *ipv6Address = [self primaryNetworkIPv6AddressFromSystemConfiguration];
    if (ipv6Address.length)
    {
        return ipv6Address;
    }
    return nil;
}

+ (NSString *)primaryNetworkIPAddressForURL
{
    NSString *ipv4Address = [self primaryNetworkIPv4AddressFromSystemConfiguration];
    if (ipv4Address.length)
    {
        return ipv4Address;
    }
    NSString *ipv6Address = [self primaryNetworkIPv6AddressFromSystemConfiguration];
    if (ipv6Address.length)
    {
        return [NSString stringWithFormat:@"[%@]", ipv6Address];
    }
    return nil;
}

+ (NSString *)primaryNetworkIPv4AddressFromSystemConfiguration
{
    NSArray *primaryAddressArray = [self primaryNetworkIPv4AddressArrayFromSystemConfiguration];
    if (primaryAddressArray.count != 0)
    {
        return primaryAddressArray[0];
    }
    return nil;
}

+ (NSArray *)primaryNetworkIPv4AddressArrayFromSystemConfiguration
{
    NSDictionary *addressInfo = [self primaryNetworkIPv4AddressInfoFromSystemConfiguration];
    NSArray *ipAddressArray = addressInfo[@"Addresses"];
    return ipAddressArray;
}

+ (NSDictionary *)primaryNetworkIPv4AddressInfoFromSystemConfiguration
{
    SCDynamicStoreRef storeRef = SCDynamicStoreCreate(NULL, (CFStringRef)@"FindCurrentInterfaceIpMac", NULL, NULL);
    if (!storeRef)
    {
        return nil;
    }
    
    NSDictionary *IPv4Dictionary = nil;
    CFPropertyListRef global = SCDynamicStoreCopyValue(storeRef, CFSTR("State:/Network/Global/IPv4"));
    id primaryInterface = [(NSDictionary *)CFBridgingRelease(global) valueForKey:@"PrimaryInterface"];
    if (primaryInterface)
    {
        NSString *interfaceState = @"State:/Network/Interface/";
        interfaceState = [[interfaceState stringByAppendingString:(NSString *)primaryInterface] stringByAppendingString:@"/IPv4"];
        CFPropertyListRef IPv4PropertyList = SCDynamicStoreCopyValue(storeRef, (__bridge CFStringRef)interfaceState);
        IPv4Dictionary = (NSDictionary *)CFBridgingRelease(IPv4PropertyList);
    }

    CFRelease(storeRef);
    return IPv4Dictionary;
}

+ (NSString *)primaryNetworkIPv6AddressFromSystemConfiguration
{
    NSArray *primaryAddressArray = [self primaryNetworkIPv6AddressArrayFromSystemConfiguration];
    for (NSString *address in primaryAddressArray)
    {
        if ([address isKindOfClass:[NSString class]] &&
            ![address isEqualToString:@"::1"] && //localhost
            ![address hasPrefix:@"fe80:"] //self assigned address
            )
        {
            return address;
        }
    }
    return nil;
}

+ (NSArray *)primaryNetworkIPv6AddressArrayFromSystemConfiguration
{
    NSDictionary *addressInfo = [self primaryNetworkIPv6AddressInfoFromSystemConfiguration];
    NSArray *ipAddressArray = addressInfo[@"Addresses"];
    return ipAddressArray;
}

+ (NSDictionary *)primaryNetworkIPv6AddressInfoFromSystemConfiguration
{
    SCDynamicStoreRef storeRef = SCDynamicStoreCreate(NULL, (CFStringRef)@"FindCurrentInterfaceIpMac", NULL, NULL);
    if (!storeRef)
    {
        return nil;
    }
    
    NSDictionary *IPv6Dictionary = nil;
    CFPropertyListRef global = SCDynamicStoreCopyValue(storeRef, CFSTR("State:/Network/Global/IPv6"));
    id primaryInterface = [(NSDictionary *)CFBridgingRelease(global) valueForKey:@"PrimaryInterface"];
    if (primaryInterface)
    {
        NSString *interfaceState = @"State:/Network/Interface/";
        interfaceState = [[interfaceState stringByAppendingString:(NSString *)primaryInterface] stringByAppendingString:@"/IPv6"];
        CFPropertyListRef IPv6PropertyList = SCDynamicStoreCopyValue(storeRef, (__bridge CFStringRef)interfaceState);
        IPv6Dictionary = (NSDictionary *)CFBridgingRelease(IPv6PropertyList);
    }
    
    CFRelease(storeRef);
    return IPv6Dictionary;
}

+ (NSArray *)addressesFromNSHost
{
    NSArray *addresses = [[NSHost currentHost] addresses];
    return addresses;
}

+ (NSDictionary *)IPv4AddressesFromGetIfAddrs
{
    NSMutableDictionary *addressDictionary = [NSMutableDictionary dictionary];
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *currentAddress = NULL;
    
    int success = getifaddrs(&interfaces);
    if (success == 0)
    {
        currentAddress = interfaces;
        while(currentAddress != NULL)
        {
            if(currentAddress->ifa_addr->sa_family == AF_INET)
            {
                void *tmpAddrPtr=&((struct sockaddr_in *)currentAddress->ifa_addr)->sin_addr;
                char addressBuffer[INET_ADDRSTRLEN];
                inet_ntop(AF_INET, tmpAddrPtr, addressBuffer, INET_ADDRSTRLEN);
                NSString *address = [NSString stringWithUTF8String:addressBuffer];
                NSString *name = [NSString stringWithUTF8String:currentAddress->ifa_name];
                if (![address isEqualToString:@"127.0.0.1"] && //localhost
                    ![address hasPrefix:@"169.254"]) //self assigned address
                {
                    [addressDictionary setObject:name forKey:address];
                }
            }
            currentAddress = currentAddress->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    NSDictionary *result = [NSDictionary dictionaryWithDictionary:addressDictionary];
    return result;
}

+ (NSDictionary *)IPv6AddressesFromGetIfAddrs
{
    NSMutableDictionary *addressDictionary = [NSMutableDictionary dictionary];
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *currentAddress = NULL;
    
    int success = getifaddrs(&interfaces);
    if (success == 0)
    {
        currentAddress = interfaces;
        while(currentAddress != NULL)
        {
            if(currentAddress->ifa_addr->sa_family == AF_INET6)
            {
                void *tmpAddrPtr=&((struct sockaddr_in6 *)currentAddress->ifa_addr)->sin6_addr;
                char addressBuffer[INET6_ADDRSTRLEN];
                inet_ntop(AF_INET6, tmpAddrPtr, addressBuffer, INET6_ADDRSTRLEN);
                NSString *address = [NSString stringWithUTF8String:addressBuffer];
                NSString *name = [NSString stringWithUTF8String:currentAddress->ifa_name];
                if (![address isEqualToString:@"::1"] && //localhost
                    ![address hasPrefix:@"fe80:"] //self assigned address
                    )
                {
                    [addressDictionary setObject:name forKey:address];
                }
            }
            currentAddress = currentAddress->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    NSDictionary *result = [NSDictionary dictionaryWithDictionary:addressDictionary];
    return result;
}

+ (NSArray *)macAddressesFromGetIfAddrs
{
    NSMutableArray *addresses = [NSMutableArray array];
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *currentAddress = NULL;
    int success = getifaddrs(&interfaces);
    if (success == 0)
    {
        currentAddress = interfaces;
        while(currentAddress != NULL)
        {
            if(currentAddress->ifa_addr->sa_family == AF_LINK)
            {
                NSString *address = [NSString stringWithUTF8String:ether_ntoa((const struct ether_addr *)LLADDR((struct sockaddr_dl *)currentAddress->ifa_addr))];
                
                // ether_ntoa doesn't format the ethernet address with padding.
                char paddedAddress[80];
                int a,b,c,d,e,f;
                sscanf([address UTF8String], "%x:%x:%x:%x:%x:%x", &a, &b, &c, &d, &e, &f);
                sprintf(paddedAddress, "%02X:%02X:%02X:%02X:%02X:%02X",a,b,c,d,e,f);
                address = [NSString stringWithUTF8String:paddedAddress];
                
                if (![address isEqual:@"00:00:00:00:00:00"] && ![address isEqual:@"00:00:00:00:00:FF"])
                {
                    [addresses addObject:address];
                }
            }
            currentAddress = currentAddress->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    return addresses;
}

@end
