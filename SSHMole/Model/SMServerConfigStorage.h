//
//  SMServerConfigStorage.h
//  SSHMole
//
//  Created by openthread on 4/4/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMServerConfig.h"
#import <AppKit/AppKit.h>

@interface SMServerConfigStorage : NSObject

+ (instancetype)defaultStorage;

- (NSArray *)configs;

- (void)addConfig:(SMServerConfig *)config;

- (void)insertConfig:(SMServerConfig *)config atIndex:(NSUInteger)index;

- (void)removeConfig:(SMServerConfig *)config;

- (NSArray *)sameServerConfigWithConfig:(SMServerConfig *)config;

@end
