//
//  YYYDownloadFolderObserver.m
//  163Music
//
//  Created by openthread on 9/5/14.
//  Copyright (c) 2014 openthread. All rights reserved.
//

#import "SMFileSystemObserver.h"
#import "SCEvents.h"
#import "SCEvent.h"

@interface SMFileSystemObserver () <SCEventListenerProtocol>
{
    SCEvents *_events;
    NSString *_observingPath;
}

@end

@implementation SMFileSystemObserver

- (id)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

- (void)dealloc
{
    [self stopObserve];
}

- (void)beginObserve
{
    if (!_observingPath)
    {
        return;
    }
    if (_events)
    {
        [_events stopWatchingPaths];
        _events = nil;
    }
    NSURL *observingURL = [NSURL fileURLWithPath:_observingPath];
    if (!observingURL)
    {
        return;
    }
    _events = [[SCEvents alloc] init];
    [_events setDelegate:self];
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
        queue = dispatch_queue_create([[NSString stringWithFormat:@"SMFileSystemObserver.%@", self] UTF8String], NULL);
    });
    
    __weak id weakSelf = self;
    dispatch_async(queue, ^{
        [weakSelf handlePathWatch:pathWatcher eventOccurred:event];
    });
}

- (void)handlePathWatch:(SCEvents *)pathWatch eventOccurred:(SCEvent *)event
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:event.eventPath])
    {
        [self.delegate fileSystemObserverFileDeletedEvent:self];
    }
}

@end
