//
//  YYYDownloadFolderObserver.h
//  163Music
//
//  Created by openthread on 9/5/14.
//  Copyright (c) 2014 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SMFileSystemObserver;

@protocol SMFileSystemObserverDelegate <NSObject>

- (void)fileSystemObserver:(SMFileSystemObserver *)observer fileRemovedPaths:(NSArray *)removedPaths;
- (void)fileSystemObserver:(SMFileSystemObserver *)observer fileAddedInPaths:(NSArray *)addedPaths;

@end

@interface SMFileSystemObserver : NSObject

@property (nonatomic, retain) NSString *observingPath;//set observing path before begin observe
@property (nonatomic, retain) NSArray *excludedPaths;//set excluded paths before begin observe
- (void)beginObserve;
- (void)stopObserve;
- (void)addDelegate:(id<SMFileSystemObserverDelegate>)delegate;
- (void)removeDelegate:(id<SMFileSystemObserverDelegate>)delegate;

@end
