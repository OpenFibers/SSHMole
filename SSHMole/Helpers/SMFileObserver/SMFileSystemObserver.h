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

- (void)fileSystemObserverFileChangedEvent:(SMFileSystemObserver *)observer;
- (void)fileSystemObserverFileDeletedEvent:(SMFileSystemObserver *)observer;

@end

@interface SMFileSystemObserver : NSObject

@property (nonatomic, strong) NSString *observingPath;//set observing path before begin observe
@property (nonatomic, weak) id<SMFileSystemObserverDelegate> delegate;

- (void)beginObserve;
- (void)stopObserve;

@end
