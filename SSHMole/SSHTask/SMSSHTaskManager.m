//
//  SMSSHTaskManager.m
//  SSHMole
//
//  Created by openthread on 4/6/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMSSHTaskManager.h"

@implementation SMSSHTaskManager
{
    SMSSHTask *_currentTask;
}

+ (instancetype)defaultManager
{
    static SMSSHTaskManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SMSSHTaskManager alloc] init];
    });
    return manager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(disconnect)
                                                     name:NSApplicationWillTerminateNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)beginConnectWithServerConfig:(SMServerConfig *)config
                            callback:(void(^)(SMSSHTaskStatus status, NSError *error))callback
{
    if (_currentTask)
    {
        [_currentTask disconnect];
        _currentTask = nil;
    }
    _currentTask = [[SMSSHTask alloc] initWithServerConfig:config];
    _currentTask.shouldLogTaskStdOut = YES;
    _currentTask.callback = ^(SMSSHTaskStatus status, NSError *error) {
        callback(status, error);
    };
    [_currentTask connect];
}

- (void)disconnect
{
    [_currentTask disconnect];
    _currentTask = nil;
}

- (SMSSHTaskStatus)currentConnectionStatus
{
    return _currentTask.currentStatus;
}

- (SMServerConfig *)connectingConfig
{
    return _currentTask.config;
}

@end
