//
//  ViewController.h
//  SSHMole
//
//  Created by openthread on 4/4/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@class SMServerConfig;
@class SMServerConfigView;

@protocol SMServerConfigViewDelegate <NSObject>

- (void)serverConfigViewConnectButtonTouched:(SMServerConfigView *)configView;
- (void)serverConfigViewSaveButtonTouched:(SMServerConfigView *)view;

@end

@interface SMServerConfigView : NSView

@property (nonatomic, weak) IBOutlet id<SMServerConfigViewDelegate> delegate;
#warning 增加readonly方法读取config view的设置
- (void)setServerConfig:(SMServerConfig *)config;//only for display, view will not retain config reference

@end

