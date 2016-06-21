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
#import "SMIPAddressHelper.h"
#import <AppKit/AppKit.h>

static const NSUInteger kSMUserProxySettingsManagerPACServerPort = 9099;

NSString *SMUserProxySettingsManagerProxyDidUpdateNotification = @"SMUserProxySettingsManagerProxyDidUpdateNotification";

@interface SMUserProxySettingsManager () <SMSystemPreferenceManagerDelegate>

@end

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
        _systemPreferenceManager = [[SMSystemPreferenceManager alloc] init];
        _systemPreferenceManager.delegate = self;
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
        [_systemPreferenceManager updateCurrentProxySettingsForConfig:nil];
        [_pacServerManager stopPacServer];
        return;
    }
    SMSystemProferenceManagerProxyMode systemPrefenceProxyMode = SMSystemProferenceManagerProxyModeOff;
    switch (self.proxyMode)
    {
        case SMUserProxySettingsManagerProxyModeOff:
        {
            systemPrefenceProxyMode = SMSystemProferenceManagerProxyModeOff;
        }
            break;
        case SMUserProxySettingsManagerProxyModeGlobal:
        {
            systemPrefenceProxyMode = SMSystemProferenceManagerProxyModeGlobal;
        }
            break;
        case SMUserProxySettingsManagerProxyModeAutoBlackList:
        {
            systemPrefenceProxyMode = SMSystemProferenceManagerProxyModeAutoBlacklist;
        }
            break;
        case SMUserProxySettingsManagerProxyModeAutoWhiteList:
        {
            systemPrefenceProxyMode = SMSystemProferenceManagerProxyModeAutoWhitelist;
        }
            break;
    }
    
    [self restartPACServerWithProxyMode:self.proxyMode];
    
    NSString *ipAddress = _currentServerConfig.allowConnectionFromLAN ? [SMIPAddressHelper primaryNetworkIPAddressForURL] : @"127.0.0.1";
    NSString *whitelistPACURLString = [NSString stringWithFormat:@"http://%@:%tu/whitelist.pac",
                                       ipAddress,
                                       kSMUserProxySettingsManagerPACServerPort];
    NSString *blacklistPACURLString = [NSString stringWithFormat:@"http://%@:%tu/blacklist.pac",
                                       ipAddress,
                                       kSMUserProxySettingsManagerPACServerPort];
    _systemPreferenceManager.whitelistPACURLString = whitelistPACURLString;
    _systemPreferenceManager.blacklistPACURLString = blacklistPACURLString;
    _systemPreferenceManager.proxyMode = systemPrefenceProxyMode;
    [_systemPreferenceManager updateCurrentProxySettingsForConfig:_currentServerConfig];
}

- (BOOL)restartPACServerWithProxyMode:(SMUserProxySettingsManagerProxyMode)proxyMode
{
    [_pacServerManager stopPacServer];
    
    //added server handler for direct mode
    NSString *directPACPathInBundle = [[NSBundle mainBundle] pathForResource:@"direct.pac" ofType:@""];
    NSData *directData = [[NSData alloc] initWithContentsOfFile:directPACPathInBundle];
    if (directData)
    {
        [_pacServerManager addHandlerForPath:@"/direct.pac" data:directData];
        if (proxyMode == SMUserProxySettingsManagerProxyModeOff)
        {
            [_pacServerManager addHandlerForPath:@"/mirror.pac" data:directData];
        }
    }
    
    //added server handler for global mode
    NSData *globalData = [_pacDownloadManger getGlobalLocalPacDataForLocalPort:_currentServerConfig.localPort
                                                       allowConnectionsFromLAN:_currentServerConfig.allowConnectionFromLAN];
    if (globalData)
    {
        [_pacServerManager addHandlerForPath:@"/global.pac" data:globalData];
        if (proxyMode == SMUserProxySettingsManagerProxyModeGlobal)
        {
            [_pacServerManager addHandlerForPath:@"/mirror.pac" data:globalData];
        }
    }
    
    //added server handler for blacklist mode
    NSData *blacklistData = [_pacDownloadManger getBlackListLocalPacDataForLocalPort:_currentServerConfig.localPort
                                                             allowConnectionsFromLAN:_currentServerConfig.allowConnectionFromLAN];
    if (blacklistData)
    {
        [_pacServerManager addHandlerForPath:@"/blacklist.pac" data:blacklistData];
        if (proxyMode == SMUserProxySettingsManagerProxyModeAutoBlackList)
        {
            [_pacServerManager addHandlerForPath:@"/mirror.pac" data:blacklistData];
        }
    }
    
    //added server handler for whitelist mode
    NSData *whitelistData = [_pacDownloadManger getWhiteListLocalPacDataForLocalPort:_currentServerConfig.localPort
                                                             allowConnectionsFromLAN:_currentServerConfig.allowConnectionFromLAN];
    if (whitelistData)
    {
        [_pacServerManager addHandlerForPath:@"/whitelist.pac" data:whitelistData];
        if (proxyMode == SMUserProxySettingsManagerProxyModeAutoWhiteList)
        {
            [_pacServerManager addHandlerForPath:@"/mirror.pac" data:whitelistData];
        }
    }
    
    //Try begin pac server
    NSError *error = nil;
    [_pacServerManager beginPacServerWithPort:kSMUserProxySettingsManagerPACServerPort
                                        error:&error];
    if (error)
    {
        NSString *errorString = [NSString stringWithFormat:@"%@\n%@", error.domain, error.localizedDescription];
        [SMAlertHelper showAlertWithOKButtonAndString:errorString];
        return NO;
    }
    return YES;
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

#pragma mark - System Preference Manager Delegate

- (void)systemPreferenceManager:(SMSystemPreferenceManager *)manager didUpdateProxyWithInfo:(NSDictionary *)proxyInfo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SMUserProxySettingsManagerProxyDidUpdateNotification object:self userInfo:proxyInfo];
}

@end
