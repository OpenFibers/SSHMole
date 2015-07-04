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
#import "NSObject+OTRuntimeUserInfo.h"
#import "SMSSHTaskManager.h"
#import "SMStatusBarUserDefaultsManager.h"
#import "SMPACFileObserverManager.h"
#import "SMLaunchManager.h"
#import <AppKit/AppKit.h>

@interface SMStatusBarController () <SMPACFileObserverManagerFileAddedDelegate, SMPACFileObserverManagerFileModifiedDelegate>
@property (nonatomic, strong) NSStatusItem *statusBar;
@property (nonatomic, strong) NSMenu *statusBarMenu;
@property (nonatomic, assign) SMStatusBarControllerProxyMode currentProxyMode;
@property (nonatomic, assign) SMSSHTaskStatus currentSSHTaskStatus;
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
    
    //Launches at user login
    NSMenuItem *_launchesAtUserLoginItem;
    
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
        [self installSSHTaskCallback];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(serverConfigsUpdated:)
                                                     name:SMServerListViewAnyConfigChangedNotification
                                                   object:nil];
        [SMPACFileObserverManager defaultManager].pacAddDelegate = self;
        [SMPACFileObserverManager defaultManager].pacModifyDelegate = self;
    }
    return self;
}

- (void)dealloc
{
    [self uninstallSSHTaskCallback];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initStatusBarIcon
{
    //Init status bar icon
    self.statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:22];
    NSImage *statusBarImage = [NSImage imageNamed:@"StatusBarPawIcon"];
    [statusBarImage setTemplate:YES];
    self.statusBar.image = statusBarImage;
    self.statusBar.title = @"";
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
    
    //Launches at user login
    {
        [self.statusBarMenu addItem:[NSMenuItem separatorItem]];
        _launchesAtUserLoginItem = [[NSMenuItem alloc] initWithTitle:@"Launches at Login" action:@selector(launchesAtUserLoginItemClicked:) keyEquivalent:@""];
        _launchesAtUserLoginItem.target = self;
        [_launchesAtUserLoginItem setState:[SMLaunchManager defaultManager].isAppLaunchesAtUserLogin];
        [self.statusBarMenu addItem:_launchesAtUserLoginItem];
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
    self.currentProxyMode = [SMStatusBarUserDefaultsManager defaultManager].lastProxyMode;
}

#pragma mark - SSH Task Callback

- (void)installSSHTaskCallback
{
    __weak id weakSelf = self;
    [[SMSSHTaskManager defaultManager] addCallback:^(SMSSHTask *task, SMSSHTaskStatus status, NSError *error) {
        if (error.code != SMSSHTaskErrorCodeDisconnectForAppTermination)//App terminate时不需要更新UI和保存user defaults
        {
            [weakSelf updateServerConfig:task.config forSSHTaskStatus:status];
        }
    } forKey:NSStringFromClass([self class])];
}

- (void)uninstallSSHTaskCallback
{
    [[SMSSHTaskManager defaultManager] removeCallbackForKey:NSStringFromClass([self class])];
}

#pragma mark - Properties

- (void)setCurrentProxyMode:(SMStatusBarControllerProxyMode)currentProxyMode
{
    _currentProxyMode = currentProxyMode;
    
    //update menu UI
    [_proxyOffItem setState:(currentProxyMode == _proxyOffItem.tag ? NSOnState : NSOffState)];
    [_whitelistModeItem setState:(currentProxyMode == _whitelistModeItem.tag ? NSOnState : NSOffState)];
    [_blacklistModeItem setState:(currentProxyMode == _blacklistModeItem.tag ? NSOnState : NSOffState)];
    [_globalModeItem setState:(currentProxyMode == _globalModeItem.tag ? NSOnState : NSOffState)];
    
    //update status bar UI
    [self updateStatusItemUIForCurrentSSHTaskStatusAndProxyMode];
    
    //update user defaults
    [SMStatusBarUserDefaultsManager defaultManager].lastProxyMode = currentProxyMode;
    
    //callback delegate
    [self.delegate statusBarController:self changeProxyModeMenuClickedWithMode:currentProxyMode];
}

#pragma mark - Server configs updated notification

- (void)updateStatusItemUIForCurrentSSHTaskStatusAndProxyMode
{
    if (self.currentSSHTaskStatus == SMSSHTaskStatusDisconnected || self.currentSSHTaskStatus == SMSSHTaskStatusErrorOccured)
    {
        self.statusBar.title = @"";
        self.statusBar.length = 22.f;
    }
    else if (self.currentSSHTaskStatus == SMSSHTaskStatusConnecting)
    {
        self.statusBar.title = @"...";
        self.statusBar.length = 44.f;
    }
    else if (self.currentSSHTaskStatus == SMSSHTaskStatusConnected)
    {
        if (self.currentProxyMode == SMStatusBarControllerProxyModeAutoBlacklist)
        {
            self.statusBar.title = @"B";
            self.statusBar.length = 44.f;
        }
        else if (self.currentProxyMode == SMStatusBarControllerProxyModeAutoWhitelist)
        {
            self.statusBar.title = @"W";
            self.statusBar.length = 44.f;
        }
        else if (self.currentProxyMode == SMStatusBarControllerProxyModeGlobal)
        {
            self.statusBar.title = @"G";
            self.statusBar.length = 44.f;
        }
        else if (self.currentProxyMode == SMStatusBarControllerProxyModeOff)
        {
            self.statusBar.title = @"";
            self.statusBar.length = 22.f;
        }
    }
}

- (void)updateServerConfig:(SMServerConfig *)config forSSHTaskStatus:(SMSSHTaskStatus)status
{
    self.currentSSHTaskStatus = status;
    
    //update menu UI
    for (NSMenuItem *item in _serverConfigItem.submenu.itemArray)
    {
        if (item != _editServerListItem && item.otRuntimeUserInfo == config)
        {
            BOOL shouldAddCheckmark = (status == SMSSHTaskStatusConnected ||
                                       status == SMSSHTaskStatusConnecting);
            if (item.state != shouldAddCheckmark)
            {
                [item setState:shouldAddCheckmark];
            }
        }
    }
    
    //update status bar UI
    [self updateStatusItemUIForCurrentSSHTaskStatusAndProxyMode];
    
    //update user defaults
    if (status == SMSSHTaskStatusDisconnected || status == SMSSHTaskStatusErrorOccured)
    {
        [SMStatusBarUserDefaultsManager defaultManager].lastConnectingConfigIdentifier = @"";
    }
    else
    {
        [SMStatusBarUserDefaultsManager defaultManager].lastConnectingConfigIdentifier = config.identifierString;
    }
}

- (void)serverConfigsUpdated:(NSNotification *)notification
{
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(serverConfigsUpdated:) withObject:notification waitUntilDone:NO];
        return;
    }
    
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
            item.otRuntimeUserInfo = config;
            item.target = self;
            [_serverConfigItem.submenu addItem:item];
        }
        [_serverConfigItem.submenu addItem:_editServerListItem];
    }
    
    //connect to last picked config, at first server config update time(app start up and server list reload)
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *lastConnectedConfigIdentifer = [SMStatusBarUserDefaultsManager defaultManager].lastConnectingConfigIdentifier;
        NSMenuItem *lastConnectedConfigItem = nil;
        for (NSMenuItem *item in _serverConfigItem.submenu.itemArray)
        {
            if (item != _editServerListItem)
            {
                SMServerConfig *config = item.otRuntimeUserInfo;
                if ([config.identifierString isEqualToString:lastConnectedConfigIdentifer])
                {
                    lastConnectedConfigItem = item;
                    break;
                }
            }
        }
        if (lastConnectedConfigItem)
        {
            [self performSelector:@selector(serverConfigItemClicked:) withObject:lastConnectedConfigItem afterDelay:1];
        }
    });
}

#pragma mark - PAC File Observer Callback

- (void)PACFileObserverManagerWhitelistPACAdded:(SMPACFileObserverManager *)manager
{
    if (self.currentProxyMode == SMStatusBarControllerProxyModeAutoWhitelist)
    {
        self.currentProxyMode = SMStatusBarControllerProxyModeOff;
        self.currentProxyMode = SMStatusBarControllerProxyModeAutoWhitelist;
    }
}

- (void)PACFileObserverManagerWhitelistPACModified:(SMPACFileObserverManager *)manager
{
    if (self.currentProxyMode == SMStatusBarControllerProxyModeAutoWhitelist)
    {
        self.currentProxyMode = SMStatusBarControllerProxyModeOff;
        self.currentProxyMode = SMStatusBarControllerProxyModeAutoWhitelist;
    }
}

- (void)PACFileObserverManagerBlacklistPACAdded:(SMPACFileObserverManager *)manager
{
    if (self.currentProxyMode == SMStatusBarControllerProxyModeAutoBlacklist)
    {
        self.currentProxyMode = SMStatusBarControllerProxyModeOff;
        self.currentProxyMode = SMStatusBarControllerProxyModeAutoBlacklist;
    }
}

- (void)PACFileObserverManagerBlacklistPACModified:(SMPACFileObserverManager *)manager
{
    if (self.currentProxyMode == SMStatusBarControllerProxyModeAutoBlacklist)
    {
        self.currentProxyMode = SMStatusBarControllerProxyModeOff;
        self.currentProxyMode = SMStatusBarControllerProxyModeAutoBlacklist;
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
    SMServerConfig *selectedConfig = item.otRuntimeUserInfo;
    [self.delegate statusBarController:self didPickServerConfig:selectedConfig];
}

- (void)launchesAtUserLoginItemClicked:(NSMenuItem *)item
{
    BOOL launchesAtLogin = [SMLaunchManager defaultManager].isAppLaunchesAtUserLogin;
    [SMLaunchManager defaultManager].isAppLaunchesAtUserLogin = !launchesAtLogin;
    [_launchesAtUserLoginItem setState:launchesAtLogin];
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
