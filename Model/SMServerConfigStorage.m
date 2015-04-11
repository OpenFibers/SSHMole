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
        [self load];
    }
    return self;
}

- (void)addConfig:(SMServerConfig *)config
{
    _serverConfigDictionary[[config accountString]] = config;
    [config saveToKeychain];
}

- (NSArray *)configs
{
    return _serverConfigDictionary.allValues;
}

- (void)removeConfig:(SMServerConfig *)config
{
    [_serverConfigDictionary removeObjectForKey:[config accountString]];
}

- (void)load
{
    NSArray *accounts = [SSKeychain accountsForService:SSHMoleKeychainServiceString];
    for (NSDictionary *eachAccountDictionary in accounts)
    {
        SMServerConfig *config = [SMServerConfig serverConfigWithKeychainAccountDictionary:eachAccountDictionary];
        _serverConfigDictionary[[config accountString]] = config;
    }
}

- (void)save
{
    for (SMServerConfig *config in _serverConfigDictionary.allValues)
    {
        [config saveToKeychain];
    }
}

@end
