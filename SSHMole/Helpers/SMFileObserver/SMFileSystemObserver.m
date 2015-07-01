//
//  YYYDownloadFolderObserver.m
//  163Music
//
//  Created by openthread on 9/5/14.
//  Copyright (c) 2014 openthread. All rights reserved.
//

#import "SMFileSystemObserver.h"
#import "SCEvents.h"
#import "NSMutableArray+WeakReferences.h"

@interface SMFileSystemObserver () <SCEventListenerProtocol>
{
    SCEvents *_events;
    NSMutableArray *_delegateArray;
    NSString *_observingPath;
}

@end

@implementation SMFileSystemObserver

- (id)init
{
    self = [super init];
    if (self)
    {
        _delegateArray = [NSMutableArray mutableArrayUsingWeakReferences];
    }
    return self;
}

- (void)dealloc
{
    [self stopObserve];
}

- (void)beginObserve
{
    if (_events)
    {
        return;
    }
    if (!_observingPath)
    {
        return;
    }
    NSURL *observingURL = [NSURL fileURLWithPath:_observingPath];
    if (!observingURL)
    {
        return;
    }
    _events = [[SCEvents alloc] init];
    [_events setDelegate:self];
	[_events setExcludedPaths:self.excludedPaths];
	[_events startWatchingPaths:@[_observingPath]];
}

- (void)stopObserve
{
    [_events stopWatchingPaths];
}

- (void)pathWatcher:(SCEvents *)pathWatcher eventOccurred:(SCEvent *)event
{
    static dispatch_queue_t queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create([[NSString stringWithFormat:@"fmdb.%@", self] UTF8String], NULL);
    });
}

- (void)addDelegate:(id<SMFileSystemObserverDelegate>)delegate
{
    if ([_delegateArray containsObject:delegate])
    {
        return;
    }
    [_delegateArray addObject:delegate];
}

- (void)removeDelegate:(id<SMFileSystemObserverDelegate>)delegate
{
    if ([_delegateArray containsObject:delegate])
    {
        [_delegateArray removeObject:delegate];
    }
}

- (void)callbackDeleagteWithAddedPaths:(NSArray *)paths
{
    for (id<SMFileSystemObserverDelegate> eachDelegate in _delegateArray)
    {
        if ([eachDelegate respondsToSelector:@selector(fileSystemObserver:fileAddedInPaths:)])
        {
            [eachDelegate fileSystemObserver:self fileAddedInPaths:paths];
        }
    }
}

- (void)callbackDeleagteWithRemovedPaths:(NSArray *)paths
{
    for (id<SMFileSystemObserverDelegate> eachDelegate in _delegateArray)
    {
        if ([eachDelegate respondsToSelector:@selector(fileSystemObserver:fileRemovedPaths:)])
        {
            [eachDelegate fileSystemObserver:self fileRemovedPaths:paths];
        }
    }
}

@end
