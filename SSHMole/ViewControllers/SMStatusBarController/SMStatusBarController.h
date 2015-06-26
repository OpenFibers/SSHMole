//
//  SMStatusBarController.h
//  SSHMole
//
//  Created by 史江浩 on 6/25/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SMStatusBarController;

typedef NS_ENUM(NSUInteger, SMStatusBarControllerProxyMode) {
    SMStatusBarControllerProxyModeOff,
    SMStatusBarControllerProxyModeAutoWhitelist,
    SMStatusBarControllerProxyModeAutoBlacklist,
    SMStatusBarControllerProxyModeGlobal,
};

@protocol SMStatusBarControllerDelegate <NSObject>

- (void)statusBarControllerEditServerListMenuClicked:(SMStatusBarController *)controller;

- (void)statusBarControllerEditPACFileMenuClicked:(SMStatusBarController *)controller;

- (void)statusBarControllerUpdateWhitelistPacMenuClicked:(SMStatusBarController *)controller;

- (void)statusBarControllerUpdateBlacklistPacMenuClicked:(SMStatusBarController *)controller;

- (void)statusBarController:(SMStatusBarController *)controller changeProxyModeMenuClickedWithMode:(SMStatusBarControllerProxyMode)mode;

@end

@interface SMStatusBarController : NSObject

@property (nonatomic, weak) id<SMStatusBarControllerDelegate> delegate;
@property (nonatomic, assign) SMStatusBarControllerProxyMode currentProxyMode;

@end
