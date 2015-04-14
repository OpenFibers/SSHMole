//
//  SMServerConfigSplitController.m
//  SSHMole
//
//  Created by openthread on 4/5/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMServerConfigSplitController.h"

//Subviews
#import "SMServerListView.h"
#import "SMServerConfigView.h"

//Managers & models
#import "SMServerConfig.h"
#import "SMServerConfigStorage.h"
#import "SMSSHTaskManager.h"

@interface SMServerConfigSplitController () <NSSplitViewDelegate, SMServerListViewDelegate, SMServerConfigViewDelegate>
@property (nonatomic, weak) IBOutlet SMServerListView *serverListView;
@property (nonatomic, weak) IBOutlet SMServerConfigView *serverConfigView;
@property (nonatomic, strong) SMServerConfig *currentConfig;
@end

@implementation SMServerConfigSplitController
{
}

#warning change connection button function for different status
#warning update traffic light color when disconnect button touched
#warning context menu and status bar icon
#warning change network settings
#warning pac server use cocoa server

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    return proposedMinimumPosition + 150.f;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    return proposedMaximumPosition - 350.f;
}

#pragma mark - List table callback

//User did select add config table row.
- (void)serverListViewDidPickAddConfig:(SMServerListView *)serverListView
{
    self.currentConfig = nil;
    
    self.serverConfigView.serverAddressString = @"";
    self.serverConfigView.serverPort = 0;//server config view will use default 22 port
    self.serverConfigView.accountString = @"";
    self.serverConfigView.passwordString = @"";
    self.serverConfigView.localPort = 0;//server config view will use default 7070 port
    self.serverConfigView.remarkString = @"";
    
    [self.serverConfigView.window makeFirstResponder:self.serverConfigView];
    
    //Update server config view UI
    [self.serverConfigView setSaveButtonEnabled:NO];
    [self updateServerConfigViewConnectButtonStatus];
}

//User did select existing server config.
- (void)serverListView:(SMServerListView *)serverListView didPickConfig:(SMServerConfig *)config
{
    self.currentConfig = config;
    
    self.serverConfigView.serverAddressString = config.serverAddress;
    self.serverConfigView.serverPort = config.serverPort;//server config view will use default 22 port
    self.serverConfigView.accountString = config.account;
    self.serverConfigView.passwordString = config.password;
    self.serverConfigView.localPort = config.localPort;//server config view will use default 7070 port
    self.serverConfigView.remarkString = config.remark;
    
    [self.serverConfigView.window makeFirstResponder:self.serverConfigView];
    
    //Update server config view UI
    [self.serverConfigView setSaveButtonEnabled:NO];
    [self updateServerConfigViewConnectButtonStatus];
}

- (void)serverListViewDeleteKeyDown:(SMServerListView *)serverListView onConfig:(SMServerConfig *)config
{
    //remove config from storage and server list view
    [[SMServerConfigStorage defaultStorage] removeConfig:config];
    [self.serverListView removeServerConfig:config];
    
    //if removing config connected, disconnect it.
    if ([[SMSSHTaskManager defaultManager] connectingConfig] == config)
    {
        [[SMSSHTaskManager defaultManager] disconnect];
    }
}

#pragma mark - Server config view call back

- (void)serverConfigViewConnectButtonTouched:(SMServerConfigView *)configView
{
    if (configView.connectButtonStatus == SMServerConfigViewConnectButtonStatusDisconnected)
    {
        [self disconnectConnectingConfig];
        [self connectCurrentConfig];
    }
    else
    {
        [self disconnectConnectingConfig];
    }
}

- (void)connectCurrentConfig
{
    //Save config if unsaved
    if (self.serverConfigView.saveButtonEnabled)
    {
        [self serverConfigViewSaveButtonTouched:self.serverConfigView];
    }
    
    NSUInteger currentConfigIndex = [self.serverListView indexOfConfig:self.currentConfig];
    
    //Make a connection
    [[SMSSHTaskManager defaultManager] beginConnectWithServerConfig:self.currentConfig callback:^(SMSSHTaskStatus status, NSError *error)
     {
         //Generate info
         NSMutableDictionary *infoDictionary = [NSMutableDictionary dictionary];
         infoDictionary[@"Status"] = [NSNumber numberWithUnsignedInteger:status];
         infoDictionary[@"ConfigIndex"] = [NSNumber numberWithUnsignedInteger:currentConfigIndex];
         if (error)
         {
             infoDictionary[@"Error"] = error;
         }
         //Call on main thread
         if ([NSThread isMainThread])
         {
             [self updateUIForConnectionStatusChangedWithInfo:infoDictionary];
         }
         else
         {
             [self performSelectorOnMainThread:@selector(updateUIForConnectionStatusChangedWithInfo:)
                                    withObject:infoDictionary
                                 waitUntilDone:NO];
         }
     }];
}

- (void)disconnectConnectingConfig
{
    SMServerConfig *connectingConfig = [[SMSSHTaskManager defaultManager] connectingConfig];
    if (!connectingConfig)
    {
        return;
    }

    //Disconnect
    [[SMSSHTaskManager defaultManager] disconnect];
    
    //Update server list view UI
    [self.serverListView reloadRowForServerConfig:connectingConfig atIndex:[self.serverListView indexOfConfig:connectingConfig]];
    
    //Update server config view UI
    [self.serverConfigView setConnectButtonStatus:SMServerConfigViewConnectButtonStatusDisconnected];
}

- (void)updateUIForConnectionStatusChangedWithInfo:(NSDictionary *)info
{
    //Update server list view UI
    NSNumber *indexNumber = info[@"ConfigIndex"];
    SMServerConfig *connectingConfig = [[SMSSHTaskManager defaultManager] connectingConfig];
    [self.serverListView reloadRowForServerConfig:connectingConfig atIndex:indexNumber.unsignedIntegerValue];
    
    //Update server config view UI
    [self updateServerConfigViewConnectButtonStatus];
    
    //Show alert if error occurred
    if (info[@"Error"])
    {
        NSError *error = info[@"Error"];
        NSAlert *alert = [[NSAlert alloc]init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:error.domain];
        [alert runModal];
    }
}

- (void)updateServerConfigViewConnectButtonStatus
{
    if (self.currentConfig == [[SMSSHTaskManager defaultManager] connectingConfig])
    {
        SMSSHTaskStatus status = [[SMSSHTaskManager defaultManager] currentConnectionStatus];
        switch (status) {
            case SMSSHTaskStatusConnected:
                self.serverConfigView.connectButtonStatus = SMServerConfigViewConnectButtonStatusConnected;
                break;
            case SMSSHTaskStatusConnecting:
                self.serverConfigView.connectButtonStatus = SMServerConfigViewConnectButtonStatusConnecting;
                break;
            case SMSSHTaskStatusDisconnected:
            case SMSSHTaskStatusErrorOccured:
                self.serverConfigView.connectButtonStatus = SMServerConfigViewConnectButtonStatusDisconnected;
                break;
            default:
                break;
        }
    }
    else
    {
        self.serverConfigView.connectButtonStatus = SMServerConfigViewConnectButtonStatusDisconnected;
    }
}

- (void)serverConfigViewSaveButtonTouched:(SMServerConfigView *)view
{
    //disable save button
    self.serverConfigView.saveButtonEnabled = NO;

    //get current editing or adding config index
    NSUInteger configIndex = [self.serverListView selectedIndex];
    
    //if current config exist, remove from server config storage
    if (self.currentConfig)
    {
        [[SMServerConfigStorage defaultStorage] removeConfig:self.currentConfig];
    }
    
    //Generate a new config
    self.currentConfig = [[SMServerConfig alloc] init];
    self.currentConfig.serverAddress = view.serverAddressString;
    self.currentConfig.serverPort = view.serverPort;
    self.currentConfig.account = view.accountString;
    self.currentConfig.password = view.passwordString;
    self.currentConfig.localPort = view.localPort;
    self.currentConfig.remark = view.remarkString;
    
    //Remove existing same config
    NSArray *sameConfigArray = [[SMServerConfigStorage defaultStorage] sameServerConfigWithConfig:self.currentConfig];
    if (sameConfigArray.count > 0)
    {
        for (SMServerConfig *existingSameConfig in sameConfigArray)
        {
            [[SMServerConfigStorage defaultStorage] removeConfig:existingSameConfig];
            [self.serverListView removeServerConfig:existingSameConfig];
            
            //if removing config connected, disconnect it.
            if ([[SMSSHTaskManager defaultManager] connectingConfig] == existingSameConfig)
            {
                [[SMSSHTaskManager defaultManager] disconnect];
            }
        }
    }
    
    NSUInteger newSavingIndex = configIndex - sameConfigArray.count;
    
    //Save to storage
    [[SMServerConfigStorage defaultStorage] insertConfig:self.currentConfig atIndex:newSavingIndex];
    
    if (newSavingIndex == [self.serverListView configCount])//If about to add
    {
        [self.serverListView addServerConfig:self.currentConfig];
    }
    else//If editing exist config
    {
        [self.serverListView reloadRowForServerConfig:self.currentConfig atIndex:newSavingIndex];
    }
}

@end
