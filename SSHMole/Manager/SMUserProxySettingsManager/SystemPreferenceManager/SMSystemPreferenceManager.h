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
    SMSystemProferenceManagerProxyModeAuto,
    SMSystemProferenceManagerProxyModeGlobal,
};

/**
 *  根据proxy mode和server config来更新系统设置。
 */
@interface SMSystemPreferenceManager : NSObject

/**
 *  生成一个system preference manager
 *
 *  @param port Pac文件的本地HTTP服务器端口
 *
 *  @return manager实例
 */
+ (instancetype)managerWithPacHTTPServerPort:(NSUInteger)port;

/**
 *  manager 当前的pac HTTP 本地端口
 */
@property (nonatomic, readonly) NSUInteger pacHTTPServerPort;

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
