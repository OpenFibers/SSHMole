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
    NSMenuItem *_serverConfigItem;
    NSMenuItem *_editServerListItem;
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
    self.statusBar.title = @"...";
    self.statusBar.highlightMode = YES;
    
    //Init status bar menu
    self.statusBarMenu = [[NSMenu alloc] initWithTitle:@""];
    self.statusBar.menu = self.statusBarMenu;
    [self initMenu];
}

- (void)initMenu
{
    {
        NSMenuItem *proxyOffItem = [[NSMenuItem alloc] initWithTitle:@"Turn Proxy Off"
                                                                action:@selector(proxyModeItemClicked:)
                                                         keyEquivalent:@""];
        proxyOffItem.target = self;
        [self.statusBarMenu addItem:proxyOffItem];
        
        NSMenuItem *globalModeItem = [[NSMenuItem alloc] initWithTitle:@"Global Proxy Mode"
                                                                action:@selector(proxyModeItemClicked:)
                                                         keyEquivalent:@""];
        globalModeItem.target = self;
        [self.statusBarMenu addItem:globalModeItem];
        
        NSMenuItem *whitelistModeItem = [[NSMenuItem alloc] initWithTitle:@"Whitelist Auto Proxy Mode"
                                                                   action:@selector(proxyModeItemClicked:)
                                                            keyEquivalent:@""];
        whitelistModeItem.target = self;
        [self.statusBarMenu addItem:whitelistModeItem];
        
        NSMenuItem *blacklistModeItem = [[NSMenuItem alloc] initWithTitle:@"Blacklist Auto Proxy Mode"
                                                                   action:@selector(proxyModeItemClicked:)
                                                            keyEquivalent:@""];
        blacklistModeItem.target = self;
        [self.statusBarMenu addItem:blacklistModeItem];
    }
    
    
    //Server config
    {
        [self.statusBarMenu addItem:[NSMenuItem separatorItem]];
        
        _serverConfigItem = [[NSMenuItem alloc] initWithTitle:@"Servers" action:nil keyEquivalent:@""];
        _serverConfigItem.target = self;
        _serverConfigItem.submenu = [[NSMenu alloc] initWithTitle:@""];
        [self.statusBarMenu addItem:_serverConfigItem];

        _editServerListItem = [[NSMenuItem alloc] initWithTitle:@"Edit Server List" action:@selector(editServerListItemClicked:) keyEquivalent:@""];
        _editServerListItem.target = self;
        [_serverConfigItem.submenu addItem:_editServerListItem];
    }
    
    //Custom PAC
    {
        [self.statusBarMenu addItem:[NSMenuItem separatorItem]];
        _serverConfigItem = [[NSMenuItem alloc] initWithTitle:@"Edit PAC for Auto Proxy Mode"
                                                       action:@selector(customPACItemClicked:)
                                                keyEquivalent:@""];
        _serverConfigItem.target = self;
        [self.statusBarMenu addItem:_serverConfigItem];
        
        _serverConfigItem = [[NSMenuItem alloc] initWithTitle:@"Update Whitelist PAC"
                                                       action:@selector(customPACItemClicked:)
                                                keyEquivalent:@""];
        _serverConfigItem.target = self;
        [self.statusBarMenu addItem:_serverConfigItem];
        
        _serverConfigItem = [[NSMenuItem alloc] initWithTitle:@"Update Blacklist PAC"
                                                       action:@selector(customPACItemClicked:)
                                                keyEquivalent:@""];
        _serverConfigItem.target = self;
        [self.statusBarMenu addItem:_serverConfigItem];
    }
    
    //Quit app
    {
        [self.statusBarMenu addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:@"Quit SSHMole"
                                                          action:@selector(quitItemClicked:)
                                                   keyEquivalent:@"q"];
        quitItem.target = self;
        [quitItem setKeyEquivalentModifierMask:NSCommandKeyMask];
        [self.statusBarMenu addItem:quitItem];
    }
}

- (void)proxyModeItemClicked:(NSMenuItem *)proxyModeItemClicked
{
    
}

- (void)editServerListItemClicked:(NSMenuItem *)editServerListItem
{
    
}

- (void)customPACItemClicked:(NSMenuItem *)sender
{
    
}

- (void)quitItemClicked:(NSMenuItem *)sender
{
    [[NSApplication sharedApplication] performSelector:@selector(terminate:) withObject:self afterDelay:0];
}

@end
