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
    NSMutableDictionary *_callbackDictionary;
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
        _callbackDictionary = [NSMutableDictionary dictionary];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(disconnectForAppTermination)
                                                     name:NSApplicationWillTerminateNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addCallback:(void(^)(SMSSHTask *task, SMSSHTaskStatus status, NSError *error))callback forKey:(NSString *)key
{
    if (key)
    {
        _callbackDictionary[key] = [callback copy];
    }
}

- (void)removeCallbackForKey:(NSString *)key
{
    if (key)
    {
        [_callbackDictionary removeObjectForKey:key];
    }
}

- (void)removeAllCallbacks
{
    [_callbackDictionary removeAllObjects];
}

- (void)beginConnectWithServerConfig:(SMServerConfig *)config
{
    if (_currentTask)
    {
        [_currentTask disconnect];
        _currentTask = nil;
    }
    _currentTask = [[SMSSHTask alloc] initWithServerConfig:config];
#ifdef DEBUG
    _currentTask.shouldLogTaskStdOut = YES;
#endif
    __weak NSMutableDictionary *weakCallbackDictionary = _callbackDictionary;
    __weak SMSSHTask *weakCurrentTask = _currentTask;
    _currentTask.callback = ^(SMSSHTaskStatus status, NSError *error)
    {
        for (void(^callback)(SMSSHTask *task, SMSSHTaskStatus status, NSError *error) in weakCallbackDictionary.allValues)
        {
            callback(weakCurrentTask ,status, error);
        }
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

- (void)disconnectForAppTermination
{
    [_currentTask disconnectForAppTermination];
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
