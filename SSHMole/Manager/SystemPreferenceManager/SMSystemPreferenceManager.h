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

@interface SMSystemPreferenceManager : NSObject

+ (instancetype)managerWithPacHTTPServerPort:(NSUInteger)port;
@property (nonatomic, assign) SMSystemProferenceManagerProxyMode proxyMode;
- (void)setCurrentProxySettingsByConfig:(SMServerConfig *)config;

@end
