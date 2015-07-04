//
//  SMFileSystemObserverManager.m
//  SSHMole
//
//  Created by openthread on 7/2/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMPACFileObserverManager.h"
#import "SMFileSystemObserver.h"
#import "SMSandboxPath.h"

@interface SMPACFileObserverManager () <SMFileSystemObserverDelegate>

@end

@implementation SMPACFileObserverManager
{
    SMFileSystemObserver *_whitelistObserver;
    SMFileSystemObserver *_blacklistObserver;
}

+ (void)load
{
    //wake manager
    [self defaultManager];
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
        _whitelistObserver = [[SMFileSystemObserver alloc] initWithObservingPath:[SMSandboxPath pacPathForName:SMSandboxWhitelistPACFileName]];
        _whitelistObserver.delegate = self;
        [_whitelistObserver beginObserve];
        
        _blacklistObserver = [[SMFileSystemObserver alloc] initWithObservingPath:[SMSandboxPath pacPathForName:SMSandboxBlacklistPACFileName]];
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

- (void)fileSystemObserverFileAddedEvent:(SMFileSystemObserver *)observer
{
    if (observer == _whitelistObserver)
    {
        [self.pacAddDelegate fileSystemObserverManagerWhitelistPACAdded:self];
    }
    else if (observer == _blacklistObserver)
    {
        [self.pacAddDelegate fileSystemObserverManagerBlacklistPACAdded:self];
    }
}

- (void)fileSystemObserverFileChangedEvent:(SMFileSystemObserver *)observer
{
    if (observer == _whitelistObserver)
    {
        [self.pacModifyDelegate fileSystemObserverManagerWhitelistPACModified:self];
    }
    else if (observer == _blacklistObserver)
    {
        [self.pacModifyDelegate fileSystemObserverManagerBlacklistPACModified:self];
    }
}

- (void)fileSystemObserverFileDeletedEvent:(SMFileSystemObserver *)observer
{
    if (observer == _whitelistObserver)
    {
        [self.pacDeleteDelegate fileSystemObserverManagerWhitelistPACDeleted:self];
    }
    else if (observer == _blacklistObserver)
    {
        [self.pacDeleteDelegate fileSystemObserverManagerBlacklistPACDeleted:self];
    }
}

@end
