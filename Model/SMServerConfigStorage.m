//
//  SMServerConfigStorage.m
//  SSHMole
//
//  Created by openthread on 4/4/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMServerConfigStorage.h"
#import "SSKeychain.h"

@implementation SMServerConfigStorage
{
    NSMutableDictionary *_serverConfigDictionary;
}

+ (instancetype)defaultStorage
{
    static SMServerConfigStorage *storage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        storage = [[SMServerConfigStorage alloc] init];
    });
    return storage;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _serverConfigDictionary = [NSMutableDictionary dictionary];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(save) name:NSApplicationWillTerminateNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addConfig:(SMServerConfig *)config
{
    _serverConfigDictionary[config.configID] = config;
}

- (void)removeConfig:(SMServerConfig *)config
{
    [_serverConfigDictionary removeObjectForKey:config.configID];
}

- (void)save
{
    
}

@end
