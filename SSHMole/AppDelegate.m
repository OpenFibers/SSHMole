//
//  AppDelegate.m
//  SSHMole
//
//  Created by openthread on 4/4/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "AppDelegate.h"
#import "SMCopyHelperWrapper.h"

@interface AppDelegate ()
@property (nonatomic, strong) NSWindowController *windowController;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //Install change system network setting helper.
    [SMCopyHelperWrapper installHelperIfNotExist];
    
    NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    self.windowController = [storyboard instantiateControllerWithIdentifier:@"ServerConfigController"];
    [self.windowController.window makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    [self.windowController.window makeKeyAndOrderFront:self];
    return YES;
}

@end
