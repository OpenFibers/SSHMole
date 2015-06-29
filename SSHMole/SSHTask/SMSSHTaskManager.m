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
        //Error occurred 和 disconnect 的 callback 没有时序保证
        //所以在Error occurred 或 disconnect 时不会clear _currentTask
        //防止后到的状态无法回调
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
    if (_currentTask.connected || _currentTask.connectionInProgress)
    {
        return _currentTask.config;
    }
    
    //有时_currentTask已断开，但_currentTask不是nil，这时强制返回nil
    return nil;
}

@end
