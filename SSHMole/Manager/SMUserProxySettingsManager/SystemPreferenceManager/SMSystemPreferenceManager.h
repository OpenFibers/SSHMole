//
//  SMSystemPreferenceManager.h
//  SSHMole
//
//  Created by openthread on 6/8/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SMServerConfig;
@class SMSystemPreferenceManager;

FOUNDATION_EXTERN NSString *SMSystemPreferenceManagerOffProxyInfoKey;
FOUNDATION_EXTERN NSString *SMSystemPreferenceManagerGlobalProxyInfoKey;
FOUNDATION_EXTERN NSString *SMSystemPreferenceManagerAutoProxyInfoKey;

typedef NS_ENUM(NSUInteger, SMSystemProferenceManagerProxyMode) {
    SMSystemProferenceManagerProxyModeOff = 0,
    SMSystemProferenceManagerProxyModeAutoWhitelist,
    SMSystemProferenceManagerProxyModeAutoBlacklist,
    SMSystemProferenceManagerProxyModeGlobal,
};

@protocol SMSystemPreferenceManagerDelegate <NSObject>

- (void)systemPreferenceManager:(SMSystemPreferenceManager *)manager didUpdateProxyWithInfo:(NSDictionary *)proxyInfo;

@end

/**
 *  根据proxy mode和server config来更新系统设置。
 */
@interface SMSystemPreferenceManager : NSObject

/**
 *  初始化一个system preference manager
 *
 *  @return @return manager实例
 */
- (id)init;

/**
 *  Delegate, type is SMSystemPreferenceManagerDelegate
 */
@property (nonatomic, weak) id<SMSystemPreferenceManagerDelegate> delegate;

/**
 *  白名单的PAC URl String。
 *  setProxyMode: 和 updateCurrentProxySettingsForConfig: 时会使用这个属性。
 *  所以务必在上述两个方法调用前更新此属性。
 */
@property (nonatomic, strong) NSString *whitelistPACURLString;

/**
 *  黑名单的PAC URL String。
 *  setProxyMode: 和 updateCurrentProxySettingsForConfig: 时会使用这个属性。
 *  所以务必在上述两个方法调用前更新此属性。
 */
@property (nonatomic, strong) NSString *blacklistPACURLString;

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
