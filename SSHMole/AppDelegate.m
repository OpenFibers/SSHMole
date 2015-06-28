//
//  AppDelegate.m
//  SSHMole
//
//  Created by openthread on 4/4/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "AppDelegate.h"
#import "SMCopyHelperWrapper.h"
#import "SMServerConfigSplitController.h"
#import "SMStatusBarController.h"
#import "SMServerConfigStorage.h"
#import "SMUserProxySettingsManager.h"
#import "SMSandboxPath.h"

@interface AppDelegate () <SMStatusBarControllerDelegate>
@property (nonatomic, strong) NSWindowController *windowController;
@property (nonatomic, strong) SMStatusBarController *statusBarController;
@property (nonatomic, readonly) SMServerConfigSplitController *contentViewController;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //Install change system network setting helper.
    [SMCopyHelperWrapper installHelperIfNotExist];
    
    //Init status bar item
    self.statusBarController = [[SMStatusBarController alloc] init];
    self.statusBarController.delegate = self;
    
    NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    self.windowController = [storyboard instantiateControllerWithIdentifier:@"ServerConfigController"];
    
    if ([[SMServerConfigStorage defaultStorage] configs].count == 0)
    {
        [self.windowController.window makeKeyAndOrderFront:self];
        [NSApp activateIgnoringOtherApps:YES];
    }
}

- (SMServerConfigSplitController *)contentViewController
{
    if ([self.windowController.contentViewController isKindOfClass:[SMServerConfigSplitController class]])
    {
        return (SMServerConfigSplitController *)self.windowController.contentViewController;
    }
    return nil;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    [self.windowController.window makeKeyAndOrderFront:self];
    return YES;
}

#pragma mark - Status bar controller callback

- (void)statusBarControllerEditServerListMenuClicked:(SMStatusBarController *)controller
{
    [self.windowController.window makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)statusBarControllerEditPACFileMenuClicked:(SMStatusBarController *)controller
{
    NSString *pacFolderPath = [SMSandboxPath pacFolderPath];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:pacFolderPath]];
}

- (void)statusBarControllerUpdateWhitelistPacMenuClicked:(SMStatusBarController *)controller
{
    
}

- (void)statusBarControllerUpdateBlacklistPacMenuClicked:(SMStatusBarController *)controller
{
    
}

- (void)statusBarController:(SMStatusBarController *)controller changeProxyModeMenuClickedWithMode:(SMStatusBarControllerProxyMode)mode
{
    switch (mode)
    {
        case SMStatusBarControllerProxyModeOff:
            [SMUserProxySettingsManager defaultManager].proxyMode = SMUserProxySettingsManagerProxyModeOff;
            break;
        case SMStatusBarControllerProxyModeAutoWhitelist:
            [SMUserProxySettingsManager defaultManager].proxyMode = SMUserProxySettingsManagerProxyModeAutoWhiteList;
            break;
        case SMStatusBarControllerProxyModeAutoBlacklist:
            [SMUserProxySettingsManager defaultManager].proxyMode = SMUserProxySettingsManagerProxyModeAutoBlackList;
            break;
        case SMStatusBarControllerProxyModeGlobal:
            [SMUserProxySettingsManager defaultManager].proxyMode = SMUserProxySettingsManagerProxyModeGlobal;
            break;
        default:
            break;
    }
}

@end
