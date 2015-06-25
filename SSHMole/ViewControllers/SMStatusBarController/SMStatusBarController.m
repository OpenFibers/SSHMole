//
//  SMStatusBarController.m
//  SSHMole
//
//  Created by 史江浩 on 6/25/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMStatusBarController.h"
#import <AppKit/AppKit.h>

@interface SMStatusBarController ()
@property (nonatomic, strong) NSStatusItem *statusBar;
@property (nonatomic, strong) NSMenu *statusBarMenu;
@end

@implementation SMStatusBarController
{
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initStatusBarIcon];
    }
    return self;
}

- (void)initStatusBarIcon
{
    //Init status bar icon
    self.statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:44];
    NSImage *statusBarImage = [NSImage imageNamed:@"StatusBarPawIcon"];
    [statusBarImage setTemplate:YES];
    self.statusBar.image = statusBarImage;
    self.statusBar.title = @"";
    self.statusBar.highlightMode = YES;
    
    //Init status bar menu
    self.statusBarMenu = [[NSMenu alloc] initWithTitle:@""];
    self.statusBar.menu = self.statusBarMenu;
    
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"aaa" action:nil keyEquivalent:@""];
    [self.statusBarMenu addItem:item];
}

@end
