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

/**
 *  替换Config
 *
 *  @param config    被替换的原始config
 *  @param newConfig 新的config
 *
 *  @return 替换的index
 */
- (NSUInteger)replaceConfig:(SMServerConfig *)config withNewConfig:(SMServerConfig *)newConfig;

- (void)removeConfig:(SMServerConfig *)config;

- (NSArray *)sameServerConfigWithConfig:(SMServerConfig *)config;

@end
