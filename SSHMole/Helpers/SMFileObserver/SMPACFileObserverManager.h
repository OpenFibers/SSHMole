//
//  SMFileSystemObserverManager.h
//  SSHMole
//
//  Created by openthread on 7/2/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SMPACFileObserverManager;

@protocol SMPACFileObserverManagerFileAddedDelegate <NSObject>

- (void)fileSystemObserverManagerWhitelistPACAdded:(SMPACFileObserverManager *)manager;
- (void)fileSystemObserverManagerBlacklistPACAdded:(SMPACFileObserverManager *)manager;

@end

@protocol SMPACFileObserverManagerFileModifiedDelegate <NSObject>

- (void)fileSystemObserverManagerWhitelistPACModified:(SMPACFileObserverManager *)manager;
- (void)fileSystemObserverManagerBlacklistPACModified:(SMPACFileObserverManager *)manager;

@end

@protocol SMPACFileObserverManagerFileDeletedDelegate <NSObject>

- (void)fileSystemObserverManagerWhitelistPACDeleted:(SMPACFileObserverManager *)manager;
- (void)fileSystemObserverManagerBlacklistPACDeleted:(SMPACFileObserverManager *)manager;

@end


@interface SMPACFileObserverManager : NSObject

+ (instancetype)defaultManager;

@property (nonatomic, weak) id<SMPACFileObserverManagerFileAddedDelegate> pacAddDelegate;
@property (nonatomic, weak) id<SMPACFileObserverManagerFileModifiedDelegate> pacModifyDelegate;
@property (nonatomic, weak) id<SMPACFileObserverManagerFileDeletedDelegate> pacDeleteDelegate;

@end

