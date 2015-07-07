//
//  SMIPAddressHelper.h
//  SSHMole
//
//  Created by openthread on 7/7/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMIPAddressHelper : NSObject

#pragma mark - Get primary network info from system configuration

#pragma mark IPv4

+ (NSString *)primaryNetworkIPv4AddressFromSystemConfiguration;

+ (NSArray *)primaryNetworkIPv4AddressArrayFromSystemConfiguration;

+ (NSDictionary *)primaryNetworkIPv4AddressInfoFromSystemConfiguration;

#pragma mark IPv6

+ (NSString *)primaryNetworkIPv6AddressFromSystemConfiguration;

+ (NSArray *)primaryNetworkIPv6AddressArrayFromSystemConfiguration;

+ (NSDictionary *)primaryNetworkIPv6AddressInfoFromSystemConfiguration;

#pragma mark - Get IP addresses from NSHost

+ (NSArray *)addressesFromNSHost;

#pragma mark - Get IP addresses and MAC addresses from ifaddrs

+ (NSDictionary *)IPv4AddressesFromGetIfAddrs;

+ (NSDictionary *)IPv6AddressesFromGetIfAddrs;

+ (NSArray *)macAddressesFromGetIfAddrs;

@end
