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
    NSMenuItem *_editPACFileItem;
    NSMenuItem *_updateWhitelistItem;
    NSMenuItem *_updateBlacklistItem;
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
    //Proxy mode
    {
        //Off
        NSMenuItem *proxyOffItem = [[NSMenuItem alloc] initWithTitle:@"Turn Proxy Off"
                                                                action:@selector(proxyModeItemClicked:)
                                                         keyEquivalent:@""];
        proxyOffItem.target = self;
        proxyOffItem.tag = SMStatusBarControllerProxyModeOff;
        [self.statusBarMenu addItem:proxyOffItem];
        
        //whitelist
        NSMenuItem *whitelistModeItem = [[NSMenuItem alloc] initWithTitle:@"Whitelist Auto Proxy Mode"
                                                                   action:@selector(proxyModeItemClicked:)
                                                            keyEquivalent:@""];
        whitelistModeItem.target = self;
        proxyOffItem.tag = SMStatusBarControllerProxyModeAutoWhitelist;
        [self.statusBarMenu addItem:whitelistModeItem];
        
        //blacklist
        NSMenuItem *blacklistModeItem = [[NSMenuItem alloc] initWithTitle:@"Blacklist Auto Proxy Mode"
                                                                   action:@selector(proxyModeItemClicked:)
                                                            keyEquivalent:@""];
        blacklistModeItem.target = self;
        proxyOffItem.tag = SMStatusBarControllerProxyModeAutoBlacklist;
        [self.statusBarMenu addItem:blacklistModeItem];
        
        //global
        NSMenuItem *globalModeItem = [[NSMenuItem alloc] initWithTitle:@"Global Proxy Mode"
                                                                action:@selector(proxyModeItemClicked:)
                                                         keyEquivalent:@""];
        globalModeItem.target = self;
        proxyOffItem.tag = SMStatusBarControllerProxyModeGlobal;
        [self.statusBarMenu addItem:globalModeItem];
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
        _editPACFileItem = [[NSMenuItem alloc] initWithTitle:@"Edit PAC for Auto Proxy Mode"
                                                       action:@selector(customPACItemClicked:)
                                                keyEquivalent:@""];
        _editPACFileItem.target = self;
        [self.statusBarMenu addItem:_editPACFileItem];
        
        _updateWhitelistItem = [[NSMenuItem alloc] initWithTitle:@"Update Whitelist PAC"
                                                          action:@selector(customPACItemClicked:)
                                                   keyEquivalent:@""];
        _updateWhitelistItem.target = self;
        [self.statusBarMenu addItem:_updateWhitelistItem];
        
        _updateBlacklistItem = [[NSMenuItem alloc] initWithTitle:@"Update Blacklist PAC"
                                                          action:@selector(customPACItemClicked:)
                                                   keyEquivalent:@""];
        _updateBlacklistItem.target = self;
        [self.statusBarMenu addItem:_updateBlacklistItem];
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
    SMStatusBarControllerProxyMode mode = proxyModeItemClicked.tag;
    [self.delegate statusBarController:self changeProxyModeMenuClickedWithMode:mode];
}

- (void)editServerListItemClicked:(NSMenuItem *)editServerListItem
{
    [self.delegate statusBarControllerEditServerListMenuClicked:self];
}

- (void)customPACItemClicked:(NSMenuItem *)sender
{
    if (sender == _editPACFileItem)
    {
        [self.delegate statusBarControllerEditPACFileMenuClicked:self];
    }
    else if (sender == _updateWhitelistItem)
    {
        [self.delegate statusBarControllerUpdateWhitelistPacMenuClicked:self];
    }
    else if (sender == _updateBlacklistItem)
    {
        [self.delegate statusBarControllerUpdateBlacklistPacMenuClicked:self];
    }
}

- (void)quitItemClicked:(NSMenuItem *)sender
{
    [[NSApplication sharedApplication] performSelector:@selector(terminate:) withObject:self afterDelay:0];
}

@end
