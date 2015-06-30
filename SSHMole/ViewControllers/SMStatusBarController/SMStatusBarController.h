//
//  SMStatusBarController.h
//  SSHMole
//
//  Created by 史江浩 on 6/25/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SMStatusBarController;
@class SMServerConfig;

typedef NS_ENUM(NSUInteger, SMStatusBarControllerProxyMode) {
    SMStatusBarControllerProxyModeOff,
    SMStatusBarControllerProxyModeAutoWhitelist,
    SMStatusBarControllerProxyModeAutoBlacklist,
    SMStatusBarControllerProxyModeGlobal,
    SMStatusBarControllerProxyModeCount,
};

@protocol SMStatusBarControllerDelegate <NSObject>

- (void)statusBarControllerEditServerListMenuClicked:(SMStatusBarController *)controller;

- (void)statusBarControllerEditPACFileMenuClicked:(SMStatusBarController *)controller;

- (void)statusBarControllerUpdateWhitelistPacMenuClicked:(SMStatusBarController *)controller;

- (void)statusBarControllerUpdateBlacklistPacMenuClicked:(SMStatusBarController *)controller;

- (void)statusBarController:(SMStatusBarController *)controller changeProxyModeMenuClickedWithMode:(SMStatusBarControllerProxyMode)mode;

- (void)statusBarController:(SMStatusBarController *)controller didPickServerConfig:(SMServerConfig *)config;

@end

@interface SMStatusBarController : NSObject

@property (nonatomic, weak) id<SMStatusBarControllerDelegate> delegate;

@end
