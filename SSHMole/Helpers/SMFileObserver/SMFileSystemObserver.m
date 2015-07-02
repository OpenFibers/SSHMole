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
    
    NSTimer *_checkFileModifyTimer;
    NSTimeInterval _lastObservingPathModifyTime;
}

@end

@implementation SMFileSystemObserver

- (id)initWithObservingPath:(NSString *)observingPath
{
    self = [super init];
    if (self)
    {
        _observingPath = observingPath;
        [self updateLastObservingPathModifyTime];
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
    
    [self beginTimer];
}

- (void)stopObserve
{
    [_events stopWatchingPaths];
    
    [self endTimer];
}

#pragma mark - SCEvent callback

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

#pragma mark - Timer methods

- (void)beginTimer
{
    if (_checkFileModifyTimer)
    {
        [_checkFileModifyTimer invalidate];
        _checkFileModifyTimer = nil;
    }
    
    _checkFileModifyTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkObservingFileModifyTime) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_checkFileModifyTimer forMode:NSRunLoopCommonModes];
    [_checkFileModifyTimer fire];
}

- (void)endTimer
{
    [_checkFileModifyTimer invalidate];
    _checkFileModifyTimer = nil;
}

- (void)checkObservingFileModifyTime
{
    NSTimeInterval lastModifyTime = _lastObservingPathModifyTime;
    [self updateLastObservingPathModifyTime];
    
    if (_lastObservingPathModifyTime != 0 && _lastObservingPathModifyTime != lastModifyTime)
    {
        if (lastModifyTime != 0)
        {
            [self.delegate fileSystemObserverFileAddedEvent:self];
        }
        else
        {
            [self.delegate fileSystemObserverFileChangedEvent:self];
        }
    }
}

- (void)updateLastObservingPathModifyTime
{
    NSError * error = nil;
    NSDictionary * attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:_observingPath error:&error];
    if (attrs && !error)
    {
        NSDate *modifyDate = [attrs fileModificationDate];
        _lastObservingPathModifyTime = [modifyDate timeIntervalSince1970];
    }
    else
    {
        _lastObservingPathModifyTime = 0;
    }
}

@end
