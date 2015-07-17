//
//  SMUserProxySettingsManager.h
//  SSHMole
//
//  Created by openthread on 6/22/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SMServerConfig;

FOUNDATION_EXTERN NSString *SMUserProxySettingsManagerProxyDidUpdateNotification;

typedef NS_ENUM(NSUInteger, SMUserProxySettingsManagerProxyMode) {
    SMUserProxySettingsManagerProxyModeOff = 0,
    SMUserProxySettingsManagerProxyModeAutoWhiteList,
    SMUserProxySettingsManagerProxyModeAutoBlackList,
    SMUserProxySettingsManagerProxyModeGlobal,
};

@interface SMUserProxySettingsManager : NSObject

+ (instancetype)defaultManager;

/**
 *  设置proxy mode，manager将根据需要自行更新系统设置，开启pac http server
 */
@property (nonatomic, assign) SMUserProxySettingsManagerProxyMode proxyMode;

/**
 *  设置server config，manager将根据需要自行更新系统设置，开启pac http server
 *
 *  @param config Server config 实例
 */
- (void)updateProxySettingsForConfig:(SMServerConfig *)config;

/**
 *  更新白名单PAC文件
 */
- (void)updateWhitelistPACFile;

/**
 *  更新黑名单PAC文件
 */
- (void)updateBlacklistPACFile;

@end
