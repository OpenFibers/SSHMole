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
@end

@implementation SMServerConfigSplitController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
//    [self testAdd];
}

- (void)testAdd
{
    SMServerConfig *config = [[SMServerConfig alloc] init];
    //    config.serverName = @"104.128.80.176";
    config.serverName = @"123123";
    config.account = @"root";
    config.password = @"234";
    config.serverPort = 22;
    config.localPort = 7070;
    
    [[SMServerConfigStorage defaultStorage] addConfig:config];
    
    [[SMSSHTaskManager defaultManager] beginConnectWithServerConfig:config callback:^(SMSSHTaskStatus status, NSError *error) {
        NSLog(@"%zd %@", status, error);
    }];
    
    [[SMSSHTaskManager defaultManager] performSelector:@selector(disconnect) withObject:nil afterDelay:10];
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    return proposedMinimumPosition + 150.f;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    return proposedMaximumPosition - 350.f;
}

//User did select add config table row.
- (void)serverListViewDidPickAddConfig:(SMServerListView *)serverListView
{
    NSLog(@"aa");
}

//User did select existing server config.
- (void)serverListView:(SMServerListView *)serverListView didPickAddConfig:(SMServerConfig *)config
{
    NSLog(@"%@", config);
}

- (void)serverConfigView:(SMServerConfigView *)connectButtonTouched
{
    
}

@end
