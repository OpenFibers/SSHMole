//
//  SMSystemPreferenceManager.m
//  SSHMole
//
//  Created by openthread on 6/8/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMSystemPreferenceManager.h"

@implementation SMSystemPreferenceManager
{
    SMServerConfig *_currentConfig;
}

+ (instancetype)defaultManager
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

- (void)setProxyMode:(SMSystemProferenceManagerProxyMode)proxyMode
{
    _proxyMode = proxyMode;
    [self updateProxySettings];
}

- (void)setCurrentProxySettingsByConfig:(SMServerConfig *)config
{
    _currentConfig = config;
    [self updateProxySettings];
}

- (void)updateProxySettings
{
    if (_currentConfig == nil)
    {
#warning clear system proxy settings
    }
    if (_proxyMode == SMSystemProferenceManagerProxyModeOff)
    {
#warning clear system proxy settings
    }
    else
    {
#warning apply proxy settings
    }
}

@end
