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

- (NSArray *)configs
{
    return [NSArray arrayWithArray:_serverConfigArray];
}

- (void)addConfig:(SMServerConfig *)config
{
    [self insertConfig:config atIndex:_serverConfigArray.count];
}

- (void)insertConfig:(SMServerConfig *)config atIndex:(NSUInteger)index
{
    if (![_serverConfigArray containsObject:config])
    {
        [_serverConfigArray insertObject:config atIndex:index];
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

- (NSArray *)sameServerConfigWithConfig:(SMServerConfig *)config
{
    NSMutableArray *sameConfigArray = [NSMutableArray array];
    for (SMServerConfig *storedConfig in _serverConfigArray)
    {
        if ([storedConfig isEqualTo:config])
        {
            [sameConfigArray addObject:storedConfig];
        }
    }
    return [NSArray arrayWithArray:sameConfigArray];
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
