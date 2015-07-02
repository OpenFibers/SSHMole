//
//  SMFileSystemObserverManager.m
//  SSHMole
//
//  Created by openthread on 7/2/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMFileSystemObserverManager.h"
#import "SMFileSystemObserver.h"
#import "SMSandboxPath.h"

@interface SMFileSystemObserverManager () <SMFileSystemObserverDelegate>

@end

@implementation SMFileSystemObserverManager
{
    SMFileSystemObserver *_whitelistObserver;
    SMFileSystemObserver *_blacklistObserver;
}

+ (void)load
{
    [self defaultManager];
#warning test code
}

+ (instancetype)defaultManager
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _whitelistObserver = [[SMFileSystemObserver alloc] init];
        _whitelistObserver.observingPath = [SMSandboxPath pacPathForName:SMSandboxWhitelistPACFileName];
        _whitelistObserver.delegate = self;
        [_whitelistObserver beginObserve];
        
        _blacklistObserver = [[SMFileSystemObserver alloc] init];
        _blacklistObserver.observingPath = [SMSandboxPath pacPathForName:SMSandboxBlacklistPACFileName];
        _blacklistObserver.delegate = self;
        [_blacklistObserver beginObserve];
    }
    return self;
}

- (void)dealloc
{
    [_whitelistObserver stopObserve];
    [_blacklistObserver stopObserve];
}

- (void)fileSystemObserverFileChangedEvent:(SMFileSystemObserver *)observer
{
    
}

- (void)fileSystemObserverFileDeletedEvent:(SMFileSystemObserver *)observer
{
    
}

@end
