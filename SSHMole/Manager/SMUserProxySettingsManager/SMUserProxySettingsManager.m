//
//  SMUserProxySettingsManager.m
//  SSHMole
//
//  Created by openthread on 6/22/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMUserProxySettingsManager.h"
#import "SMPacFileDownloadManager.h"
#import "SMWebServerManager.h"
#import "SMSystemPreferenceManager.h"
#import "SMServerConfig.h"

@implementation SMUserProxySettingsManager
{
    SMSystemPreferenceManager *_systemPreferenceManager;
    SMPacFileDownloadManager *_pacDownloadManger;
    SMWebServerManager *_pacServerManager;
    
    SMServerConfig *_currentServerConfig;
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
        _systemPreferenceManager = [SMSystemPreferenceManager managerWithPacHTTPServerPort:9099];
        _pacDownloadManger = [SMPacFileDownloadManager defaultManager];
        _pacServerManager = [SMWebServerManager defaultManager];
    }
    return self;
}

- (void)setProxyMode:(SMUserProxySettingsManagerProxyMode)proxyMode
{
    if (_proxyMode != proxyMode)
    {
        _proxyMode = proxyMode;
        [self updateSettings];
    }
}

- (void)updateProxySettingsForConfig:(SMServerConfig *)config
{
    if (_currentServerConfig != config)
    {
        _currentServerConfig = config;
        [self updateSettings];
    }
}

- (void)updateSettings
{
    SMSystemProferenceManagerProxyMode systemPrefenceProxyMode = SMSystemProferenceManagerProxyModeOff;
    switch (self.proxyMode)
    {
        case SMUserProxySettingsManagerProxyModeOff:
        {
            systemPrefenceProxyMode = SMSystemProferenceManagerProxyModeOff;
            [_pacServerManager stopPacServer];
            
        }
            break;
        case SMUserProxySettingsManagerProxyModeGlobal:
        {
            systemPrefenceProxyMode = SMSystemProferenceManagerProxyModeGlobal;
            [_pacServerManager stopPacServer];
        }
            break;
        case SMUserProxySettingsManagerProxyModeAutoBlackList:
        {
            systemPrefenceProxyMode = SMSystemProferenceManagerProxyModeAuto;
            __weak SMWebServerManager *weakPacServerManager = _pacServerManager;
            __weak SMSystemPreferenceManager *weakSystemPreferenceManager = _systemPreferenceManager;
            [_pacDownloadManger getBlackListPacDataAndUpdate:NO localPort:_currentServerConfig.localPort completion:^(NSData *data) {
                [weakPacServerManager beginPacServerWithPort:weakSystemPreferenceManager.pacHTTPServerPort
                                                        data:data
                                                        path:@"/proxy.pac"];
            }];
        }
            break;
        case SMUserProxySettingsManagerProxyModeAutoWhiteList:
        {
            systemPrefenceProxyMode = SMSystemProferenceManagerProxyModeAuto;
            __weak SMWebServerManager *weakPacServerManager = _pacServerManager;
            __weak SMSystemPreferenceManager *weakSystemPreferenceManager = _systemPreferenceManager;
            [_pacDownloadManger getWhiteListPacDataAndUpdate:NO localPort:_currentServerConfig.localPort completion:^(NSData *data) {
                [weakPacServerManager beginPacServerWithPort:weakSystemPreferenceManager.pacHTTPServerPort
                                                        data:data
                                                        path:@"/proxy.pac"];
            }];
        }
            break;
    }
    _systemPreferenceManager.proxyMode = systemPrefenceProxyMode;
    [_systemPreferenceManager updateCurrentProxySettingsForConfig:_currentServerConfig];
}

@end
