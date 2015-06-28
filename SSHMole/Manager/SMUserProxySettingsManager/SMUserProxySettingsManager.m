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
        NSString *whitelistPACURLString = @"http://127.0.0.1:9099/whitelist.pac";
        NSString *blacklistPACURLString = @"http://127.0.0.1:9099/blacklist.pac";
        _systemPreferenceManager = [[SMSystemPreferenceManager alloc] initWithWhitelistPACURLString:whitelistPACURLString
                                                                              blacklistPACURLString:blacklistPACURLString];
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
    if (!_currentServerConfig)
    {
        return;
    }
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
            systemPrefenceProxyMode = SMSystemProferenceManagerProxyModeAutoBlacklist;
            __weak SMWebServerManager *weakPacServerManager = _pacServerManager;
            [_pacDownloadManger getBlackListLocalPacDataForLocalPort:_currentServerConfig.localPort completion:^(NSData *data) {
                [weakPacServerManager beginPacServerWithPort:9099
                                                        data:data
                                                        path:@"/blacklist.pac"];
            }];
        }
            break;
        case SMUserProxySettingsManagerProxyModeAutoWhiteList:
        {
            systemPrefenceProxyMode = SMSystemProferenceManagerProxyModeAutoWhitelist;
            __weak SMWebServerManager *weakPacServerManager = _pacServerManager;
            [_pacDownloadManger getWhiteListLocalPacDataForLocalPort:_currentServerConfig.localPort completion:^(NSData *data) {
                [weakPacServerManager beginPacServerWithPort:9099
                                                        data:data
                                                        path:@"/whitelist.pac"];
            }];
        }
            break;
    }
    _systemPreferenceManager.proxyMode = systemPrefenceProxyMode;
    [_systemPreferenceManager updateCurrentProxySettingsForConfig:_currentServerConfig];
}

- (void)updateWhitelistPACFile
{
}

- (void)updateBlacklistPACFile
{
}

@end
