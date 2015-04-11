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
    
    [self.serverConfigView becomeFirstResponder];
}

//User did select existing server config.
- (void)serverListView:(SMServerListView *)serverListView didPickAddConfig:(SMServerConfig *)config
{
    self.currentConfig = config;
    
    self.serverConfigView.serverAddressString = config.serverAddress;
    self.serverConfigView.serverPort = config.serverPort;//server config view will use default 22 port
    self.serverConfigView.accountString = config.account;
    self.serverConfigView.passwordString = config.password;
    self.serverConfigView.localPort = config.localPort;//server config view will use default 7070 port
    self.serverConfigView.remarkString = config.remark;
    
    [self.serverConfigView becomeFirstResponder];
}

- (void)serverListViewDeleteKeyDown:(SMServerListView *)serverListView onConfig:(SMServerConfig *)config
{
    [[SMServerConfigStorage defaultStorage] removeConfig:config];
    [self.serverListView reloadData];
}

#pragma mark - Server config view call back

- (void)serverConfigViewConnectButtonTouched:(SMServerConfigView *)configView
{
    [[SMSSHTaskManager defaultManager] beginConnectWithServerConfig:self.currentConfig callback:^(SMSSHTaskStatus status, NSError *error) {
        NSLog(@"%zd %@", status, error);
    }];
    
    [[SMSSHTaskManager defaultManager] performSelector:@selector(disconnect) withObject:nil afterDelay:10];
}

- (void)serverConfigViewSaveButtonTouched:(SMServerConfigView *)view
{
    if (!self.currentConfig)
    {
        self.currentConfig = [[SMServerConfig alloc] init];
    }
    else
    {
        [self.currentConfig removeFromKeychain];
    }
    
    //Generate a new config
    self.currentConfig.serverAddress = view.serverAddressString;
    self.currentConfig.serverPort = view.serverPort;
    self.currentConfig.account = view.accountString;
    self.currentConfig.password = view.passwordString;
    self.currentConfig.localPort = view.localPort;
    self.currentConfig.remark = view.remarkString;
    
    //Save to storage
    [[SMServerConfigStorage defaultStorage] addConfig:self.currentConfig];
    
    [self.serverListView reloadData];
}

@end
