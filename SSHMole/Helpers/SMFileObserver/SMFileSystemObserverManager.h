//
//  SMFileSystemObserverManager.h
//  SSHMole
//
//  Created by openthread on 7/2/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SMFileSystemObserverManager;

@protocol SMFileSystemObserverManagerFileAddedDelegate <NSObject>

- (void)fileSystemObserverManagerWhitelistPACAdded:(SMFileSystemObserverManager *)manager;
- (void)fileSystemObserverManagerBlacklistPACAdded:(SMFileSystemObserverManager *)manager;

@end

@protocol SMFileSystemObserverManagerFileModifiedDelegate <NSObject>

- (void)fileSystemObserverManagerWhitelistPACModified:(SMFileSystemObserverManager *)manager;
- (void)fileSystemObserverManagerBlacklistPACModified:(SMFileSystemObserverManager *)manager;

@end

@protocol SMFileSystemObserverManagerFileDeletedDelegate <NSObject>

- (void)fileSystemObserverManagerWhitelistPACDeleted:(SMFileSystemObserverManager *)manager;
- (void)fileSystemObserverManagerBlacklistPACDeleted:(SMFileSystemObserverManager *)manager;

@end


@interface SMFileSystemObserverManager : NSObject

+ (instancetype)defaultManager;

@property (nonatomic, weak) id<SMFileSystemObserverManagerFileAddedDelegate> pacAddDelegate;
@property (nonatomic, weak) id<SMFileSystemObserverManagerFileModifiedDelegate> pacModifyDelegate;
@property (nonatomic, weak) id<SMFileSystemObserverManagerFileDeletedDelegate> pacDeleteDelegate;

@end
