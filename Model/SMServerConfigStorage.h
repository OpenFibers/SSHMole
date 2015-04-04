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

- (void)addConfig:(SMServerConfig *)config;

- (void)removeConfig:(SMServerConfig *)config;

@end
