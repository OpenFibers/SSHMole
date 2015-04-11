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
    NSMutableArray *_serverConfigArray;
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
        _serverConfigArray = [NSMutableArray array];
        [self load];
    }
    return self;
}

- (void)addConfig:(SMServerConfig *)config
{
    if (![_serverConfigArray containsObject:config])
    {
        [_serverConfigArray addObject:config];
    }
    [config saveToKeychain];
}

- (void)removeConfig:(SMServerConfig *)config
{
    if ([_serverConfigArray containsObject:config])
    {
        [_serverConfigArray removeObject:config];
    }
    [config removeFromKeychain];
}

- (NSArray *)configs
{
    return [NSArray arrayWithArray:_serverConfigArray];
}

- (void)load
{
    NSArray *accounts = [SSKeychain accountsForService:SSHMoleKeychainServiceString];
    for (NSDictionary *eachAccountDictionary in accounts)
    {
        SMServerConfig *config = [SMServerConfig serverConfigWithKeychainAccountDictionary:eachAccountDictionary];
        [_serverConfigArray addObject:config];
    }
}

- (void)save
{
    for (SMServerConfig *config in _serverConfigArray)
    {
        [config saveToKeychain];
    }
}

@end
