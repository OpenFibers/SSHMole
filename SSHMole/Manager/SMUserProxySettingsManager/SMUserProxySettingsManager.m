//
//  SMUserProxySettingsManager.m
//  SSHMole
//
//  Created by openthread on 6/22/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMUserProxySettingsManager.h"
#import "SMPACFileDownloadManager.h"
#import "SMWebServerManager.h"
#import "SMSystemPreferenceManager.h"
#import "SMServerConfig.h"
#import "SMAlertHelper.h"
#import <AppKit/AppKit.h>

@implementation SMUserProxySettingsManager
{
    SMSystemPreferenceManager *_systemPreferenceManager;
    SMPACFileDownloadManager *_pacDownloadManger;
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
        _pacDownloadManger = [SMPACFileDownloadManager defaultManager];
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
        _systemPreferenceManager.proxyMode = SMSystemProferenceManagerProxyModeOff;
        [_systemPreferenceManager updateCurrentProxySettingsForConfig:_currentServerConfig];
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
            [_pacDownloadManger getBlackListLocalPacDataForLocalPort:_currentServerConfig.localPort
                                             allowConnectionsFromLAN:_currentServerConfig.allowConnectionFromLAN
                                                          completion:^(NSData *data) {
                NSError *error = nil;
                [weakPacServerManager beginPacServerWithPort:9099
                                                        data:data
                                                        path:@"/blacklist.pac"
                                                       error:&error];
                if (error)
                {
                    NSString *errorString = [NSString stringWithFormat:@"%@\n%@", error.domain, error.localizedDescription];
                    [SMAlertHelper showAlertWithOKButtonAndString:errorString];
                }
            }];
        }
            break;
        case SMUserProxySettingsManagerProxyModeAutoWhiteList:
        {
            systemPrefenceProxyMode = SMSystemProferenceManagerProxyModeAutoWhitelist;
            __weak SMWebServerManager *weakPacServerManager = _pacServerManager;
            [_pacDownloadManger getWhiteListLocalPacDataForLocalPort:_currentServerConfig.localPort
                                             allowConnectionsFromLAN:_currentServerConfig.allowConnectionFromLAN
                                                          completion:^(NSData *data) {
                NSError *error = nil;
                [weakPacServerManager beginPacServerWithPort:9099
                                                        data:data
                                                        path:@"/whitelist.pac"
                                                       error:&error];
                if (error)
                {
                    NSString *errorString = [NSString stringWithFormat:@"%@\n%@", error.domain, error.localizedDescription];
                    [SMAlertHelper showAlertWithOKButtonAndString:errorString];
                }
            }];
        }
            break;
    }
    _systemPreferenceManager.proxyMode = systemPrefenceProxyMode;
    [_systemPreferenceManager updateCurrentProxySettingsForConfig:_currentServerConfig];
}

- (void)updateWhitelistPACFile
{
    [_pacDownloadManger updatWhitelistPACDataWithCompletion:^(BOOL successed) {
        NSString *alertMessage = @"";
        if (successed)
        {
            alertMessage = @"Update whitelist PAC file successed";
            
            //如果当前设置为白名单，切换状态，强制系统刷新proxy settings
            if (self.proxyMode == SMUserProxySettingsManagerProxyModeAutoWhiteList)
            {
                self.proxyMode = SMUserProxySettingsManagerProxyModeOff;
                self.proxyMode = SMUserProxySettingsManagerProxyModeAutoWhiteList;
            }
        }
        else
        {
            alertMessage = @"Update whitelist PAC file failed";
        }
        
        [SMAlertHelper showAlertWithOKButtonAndString:alertMessage];
    }];
}

- (void)updateBlacklistPACFile
{
    [_pacDownloadManger updateBlacklistPACDataWithCompletion:^(BOOL successed) {
        NSString *alertMessage = @"";
        if (successed)
        {
            alertMessage = @"Update blacklist PAC file successed";

            //如果当前设置为黑名单，切换状态，强制系统刷新proxy settings
            if (self.proxyMode == SMUserProxySettingsManagerProxyModeAutoBlackList)
            {
                self.proxyMode = SMUserProxySettingsManagerProxyModeOff;
                self.proxyMode = SMUserProxySettingsManagerProxyModeAutoBlackList;
            }
        }
        else
        {
            alertMessage = @"Update blacklist PAC file failed";
        }
        
        [SMAlertHelper showAlertWithOKButtonAndString:alertMessage];
    }];
}

@end
