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

/**
 *  获取当前连接的网络中最优先网络的第一个IPv4地址。如果没有网络连接则返回nil。
 *
 *  @return 当前连接的网络中最优先网络的第一个IPv4地址。如果没有网络连接则返回nil。
 */
+ (NSString *)primaryNetworkIPv4AddressFromSystemConfiguration;

/**
 *  获取当前连接的网络中最优先网络的全部IPv4地址。如果没有网络连接则返回nil。
 *
 *  @return 当前连接的网络中最优先网络的全部IPv4地址。如果没有网络连接则返回nil。
 */
+ (NSArray *)primaryNetworkIPv4AddressArrayFromSystemConfiguration;

/**
 *  获取当前连接的网络中最优先网络的全部IPv4地址及mask、广播地址。如果没有网络连接则返回nil。
 *
 *  @return 当前连接的网络中最优先网络的全部IPv4地址及mask、广播地址。如果没有网络连接则返回nil。
 */
+ (NSDictionary *)primaryNetworkIPv4AddressInfoFromSystemConfiguration;

#pragma mark IPv6

/**
 *  获取当前连接的网络中最优先网络的第一个IPv6地址。如果没有网络连接则返回nil。
 *
 *  @return 当前连接的网络中最优先网络的第一个IPv6地址。如果没有网络连接则返回nil。
 */
+ (NSString *)primaryNetworkIPv6AddressFromSystemConfiguration;

/**
 *  获取当前连接的网络中最优先网络的全部IPv6地址。如果没有网络连接则返回nil。
 *
 *  @return 当前连接的网络中最优先网络的全部IPv6地址。如果没有网络连接则返回nil。
 */
+ (NSArray *)primaryNetworkIPv6AddressArrayFromSystemConfiguration;

/**
 *  获取当前连接的网络中最优先网络的全部IPv6地址及mask、广播地址。如果没有网络连接则返回nil。
 *
 *  @return 当前连接的网络中最优先网络的全部IPv6地址及mask、广播地址。如果没有网络连接则返回nil。
 */
+ (NSDictionary *)primaryNetworkIPv6AddressInfoFromSystemConfiguration;

#pragma mark - Get IP addresses from NSHost

+ (NSArray *)addressesFromNSHost;

#pragma mark - Get IP addresses and MAC addresses from ifaddrs

+ (NSDictionary *)IPv4AddressesFromGetIfAddrs;

+ (NSDictionary *)IPv6AddressesFromGetIfAddrs;

+ (NSArray *)macAddressesFromGetIfAddrs;

@end
