//
//  SMSSHTaskManager.h
//  SSHMole
//
//  Created by openthread on 4/6/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "SMServerConfig.h"
#import "SMSSHTask.h"

@interface SMSSHTaskManager : NSObject

+ (instancetype)defaultManager;

- (void)addCallback:(void(^)(SMSSHTask *task, SMSSHTaskStatus status, NSError *error))callback forKey:(NSString *)key;
- (void)removeCallbackForKey:(NSString *)key;
- (void)removeAllCallbacks;

- (void)beginConnectWithServerConfig:(SMServerConfig *)config;
- (void)disconnect;

- (SMSSHTaskStatus)currentConnectionStatus;

- (SMServerConfig *)connectingConfig;

@end
