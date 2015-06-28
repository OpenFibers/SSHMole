//
//  SMSystemPreferenceManager.h
//  SSHMole
//
//  Created by openthread on 6/8/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SMServerConfig;

typedef NS_ENUM(NSUInteger, SMSystemProferenceManagerProxyMode) {
    SMSystemProferenceManagerProxyModeOff = 0,
    SMSystemProferenceManagerProxyModeAutoWhitelist,
    SMSystemProferenceManagerProxyModeAutoBlacklist,
    SMSystemProferenceManagerProxyModeGlobal,
};

/**
 *  根据proxy mode和server config来更新系统设置。
 */
@interface SMSystemPreferenceManager : NSObject

/**
 *  初始化一个system preference manager
 *
 *  @param whitelistPACURLString 白名单 PAC URL
 *  @param blacklistPACURLString 黑名单 PAC URL
 *
 *  @return manager实例
 */
- (id)initWithWhitelistPACURLString:(NSString *)whitelistPACURLString
              blacklistPACURLString:(NSString *)blacklistPACURLString;

/**
 *  设置proxy mode，manager将根据需要自行更新系统设置
 */
@property (nonatomic, assign) SMSystemProferenceManagerProxyMode proxyMode;

/**
 *  设置server config，manager将根据需要自行更新系统设置
 *
 *  @param config Server config 实例
 */
- (void)updateCurrentProxySettingsForConfig:(SMServerConfig *)config;

@end
