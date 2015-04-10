//
//  SMServerConfigSplitController.m
//  SSHMole
//
//  Created by openthread on 4/5/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMServerConfigSplitController.h"
#import "SMServerListView.h"
#import "SMServerConfigView.h"
#import "SMServerConfig.h"

@interface SMServerConfigSplitController () <NSSplitViewDelegate, SMServerListViewDelegate, SMServerConfigViewDelegate>
@property (nonatomic, weak) IBOutlet SMServerListView *serverListView;
@property (nonatomic, weak) IBOutlet SMServerConfigView *serverConfigView;
@end

@implementation SMServerConfigSplitController

- (void)viewDidLoad {
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
