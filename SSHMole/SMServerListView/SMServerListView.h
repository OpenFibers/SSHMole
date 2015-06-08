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
- (void)serverListView:(SMServerListView *)serverListView didPickConfig:(SMServerConfig *)config;

//Delete key down on config
- (void)serverListViewDeleteKeyDown:(SMServerListView *)serverListView onConfig:(SMServerConfig *)config;

@end

@interface SMServerListView : NSVisualEffectView

@property (nonatomic, weak) IBOutlet id<SMServerListViewDelegate> delegate;
@property (nonatomic, assign) NSUInteger selectedIndex;

- (NSUInteger)indexOfConfig:(SMServerConfig *)config;
- (NSUInteger)configCount;

/**
 *  Reload table row for a config. Find the same one by config.identifierString.
 *
 *  @param config The config to reload.
 */
- (void)reloadRowForServerConfig:(SMServerConfig *)config;

/**
 *  Reload table row for a config.
 *
 *  @param config The config to reload.
 *  @param index The specific index to reload. If passed NSNotFound, server list view will reload the existing config has the same identifierString with the inputed config.
 */
- (void)reloadRowForServerConfig:(SMServerConfig *)config atIndex:(NSUInteger)index;

- (void)addServerConfig:(SMServerConfig *)config;
- (void)insertServerConfig:(SMServerConfig *)config atIndex:(NSUInteger)index;
- (void)removeServerConfig:(SMServerConfig *)config;
- (void)selectConfig:(SMServerConfig *)config;

@end
