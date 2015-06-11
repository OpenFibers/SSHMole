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

- (void)beginConnectWithServerConfig:(SMServerConfig *)config
                            callback:(void(^)(SMSSHTaskStatus status, NSError *error))callback;
- (void)disconnect;

- (SMSSHTaskStatus)currentConnectionStatus;

- (SMServerConfig *)connectingConfig;

@end
