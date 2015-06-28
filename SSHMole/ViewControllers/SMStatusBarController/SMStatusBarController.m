//
//  SMStatusBarController.m
//  SSHMole
//
//  Created by 史江浩 on 6/25/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMStatusBarController.h"
#import "SMServerListView.h"
#import "SMServerConfig.h"
#import <AppKit/AppKit.h>

@interface SMStatusBarController ()
@property (nonatomic, strong) NSStatusItem *statusBar;
@property (nonatomic, strong) NSMenu *statusBarMenu;
@property (nonatomic, assign) SMStatusBarControllerProxyMode currentProxyMode;
@end

@implementation SMStatusBarController
{
    //Proxy mode menu items
    NSMenuItem *_proxyOffItem;
    NSMenuItem *_whitelistModeItem;
    NSMenuItem *_blacklistModeItem;
    NSMenuItem *_globalModeItem;
    
    //Server config menu items
    NSMenuItem *_serverConfigItem;
    NSMenuItem *_editServerListItem;
    
    //Edit PAC files items
    NSMenuItem *_editPACFileItem;
    NSMenuItem *_updateWhitelistItem;
    NSMenuItem *_updateBlacklistItem;
}

#pragma mark - Init methods

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initStatusBarIcon];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(serverConfigsUpdated:)
                                                     name:SMServerListViewAnyConfigChangedNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    //Get last config
    [self performSelector:@selector(initProxyModeConfig) withObject:nil afterDelay:0];
}

- (void)initMenu
{
    //Proxy mode
    {
        //Off
        _proxyOffItem = [[NSMenuItem alloc] initWithTitle:@"Turn Proxy Off"
                                                                action:@selector(proxyModeItemClicked:)
                                                         keyEquivalent:@""];
        _proxyOffItem.target = self;
        _proxyOffItem.tag = SMStatusBarControllerProxyModeOff;
        [self.statusBarMenu addItem:_proxyOffItem];
        
        //whitelist
        _whitelistModeItem = [[NSMenuItem alloc] initWithTitle:@"Whitelist Auto Proxy Mode"
                                                                   action:@selector(proxyModeItemClicked:)
                                                            keyEquivalent:@""];
        _whitelistModeItem.target = self;
        _whitelistModeItem.tag = SMStatusBarControllerProxyModeAutoWhitelist;
        [self.statusBarMenu addItem:_whitelistModeItem];
        
        //blacklist
        _blacklistModeItem = [[NSMenuItem alloc] initWithTitle:@"Blacklist Auto Proxy Mode"
                                                                   action:@selector(proxyModeItemClicked:)
                                                            keyEquivalent:@""];
        _blacklistModeItem.target = self;
        _blacklistModeItem.tag = SMStatusBarControllerProxyModeAutoBlacklist;
        [self.statusBarMenu addItem:_blacklistModeItem];
        
        //global
        _globalModeItem = [[NSMenuItem alloc] initWithTitle:@"Global Proxy Mode"
                                                                action:@selector(proxyModeItemClicked:)
                                                         keyEquivalent:@""];
        _globalModeItem.target = self;
        _globalModeItem.tag = SMStatusBarControllerProxyModeGlobal;
        [self.statusBarMenu addItem:_globalModeItem];
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

- (void)initProxyModeConfig
{
    self.currentProxyMode = SMStatusBarControllerProxyModeAutoWhitelist;
}

#pragma mark - Properties

- (void)setCurrentProxyMode:(SMStatusBarControllerProxyMode)currentProxyMode
{
    _currentProxyMode = currentProxyMode;
    [_proxyOffItem setState:(currentProxyMode == _proxyOffItem.tag ? NSOnState : NSOffState)];
    [_whitelistModeItem setState:(currentProxyMode == _whitelistModeItem.tag ? NSOnState : NSOffState)];
    [_blacklistModeItem setState:(currentProxyMode == _blacklistModeItem.tag ? NSOnState : NSOffState)];
    [_globalModeItem setState:(currentProxyMode == _globalModeItem.tag ? NSOnState : NSOffState)];
    
    [self.delegate statusBarController:self changeProxyModeMenuClickedWithMode:currentProxyMode];
}

#pragma mark - Server configs updated notification

- (void)serverConfigsUpdated:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSArray *configs = userInfo[SMServerListViewAnyConfigChangedNotificationServerConfigsKey];
    if (configs)
    {
        [_serverConfigItem.submenu removeAllItems];
        for (SMServerConfig *config in configs)
        {
            NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:config.accountStringForDisplay
                                                          action:@selector(serverConfigItemClicked:)
                                                   keyEquivalent:@""];
            item.target = self;
            [_serverConfigItem.submenu addItem:item];
        }
        [_serverConfigItem.submenu addItem:_editServerListItem];
    }
}

#pragma mark - Menu events

- (void)proxyModeItemClicked:(NSMenuItem *)proxyModeItemClicked
{
    SMStatusBarControllerProxyMode mode = proxyModeItemClicked.tag;
    [self setCurrentProxyMode:mode];
}

- (void)serverConfigItemClicked:(NSMenuItem *)item
{
    
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
