//
//  SMStatusBarUserDefaultsManager.m
//  SSHMole
//
//  Created by openthread on 6/30/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMStatusBarUserDefaultsManager.h"
#import <AppKit/AppKit.h>

@implementation SMStatusBarUserDefaultsManager

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
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(saveDefaults)
                                                     name:NSApplicationWillTerminateNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)saveDefaults
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (SMStatusBarControllerProxyMode)lastProxyMode
{
    NSNumber *modeNumber = [[NSUserDefaults standardUserDefaults] objectForKey:[SMStatusBarUserDefaultsManager userDefaultsKeyForShortKey:@"LastProxyMode"]];
    if (!modeNumber)
    {
        return SMStatusBarControllerProxyModeAutoBlacklist;
    }
    else if (modeNumber.integerValue > SMStatusBarControllerProxyModeCount)
    {
        return SMStatusBarControllerProxyModeAutoBlacklist;
    }
    return modeNumber.integerValue;
}

- (void)setLastProxyMode:(SMStatusBarControllerProxyMode)lastProxyMode
{
    NSNumber *modeNumber = [NSNumber numberWithInteger:lastProxyMode];
    [[NSUserDefaults standardUserDefaults] setObject:modeNumber
                                              forKey:[SMStatusBarUserDefaultsManager userDefaultsKeyForShortKey:@"LastProxyMode"]];
}

- (NSString *)lastConnectingConfigIdentifier
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:[SMStatusBarUserDefaultsManager userDefaultsKeyForShortKey:@"LastConnectingConfigIdentifier"]];
}

- (void)setLastConnectingConfigIdentifier:(NSString *)lastConnectingConfigIdentifier
{
    [[NSUserDefaults standardUserDefaults] setObject:lastConnectingConfigIdentifier
                                              forKey:[SMStatusBarUserDefaultsManager userDefaultsKeyForShortKey:@"LastConnectingConfigIdentifier"]];
}

+ (NSString *)userDefaultsKeyForShortKey:(NSString *)shortKey
{
    NSString *className = NSStringFromClass(self);
    NSString *result = [className stringByAppendingString:shortKey];
    return result;
}

@end
