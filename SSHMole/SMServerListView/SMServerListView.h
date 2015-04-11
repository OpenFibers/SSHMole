//
//  SMServerListViewController.h
//  SSHMole
//
//  Created by openthread on 4/5/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SMServerListView;
@class SMServerConfig;

@protocol SMServerListViewDelegate <NSObject>

//User did select add config table row.
- (void)serverListViewDidPickAddConfig:(SMServerListView *)serverListView;

//User did select existing server config.
- (void)serverListView:(SMServerListView *)serverListView didPickAddConfig:(SMServerConfig *)config;

@end

@interface SMServerListView : NSVisualEffectView

@property (nonatomic, weak) IBOutlet id<SMServerListViewDelegate> delegate;

- (void)reloadData;

@end
