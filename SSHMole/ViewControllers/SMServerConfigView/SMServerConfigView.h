//
//  ViewController.h
//  SSHMole
//
//  Created by openthread on 4/4/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SMServerConfigViewConnectButtonStatus) {
    SMServerConfigViewConnectButtonStatusDisconnected = 0,
    SMServerConfigViewConnectButtonStatusConnecting = 1,
    SMServerConfigViewConnectButtonStatusConnected = 2,
};

@class SMServerConfigView;

@protocol SMServerConfigViewDelegate <NSObject>

- (void)serverConfigViewConnectButtonTouched:(SMServerConfigView *)configView;
- (void)serverConfigViewSaveButtonTouched:(SMServerConfigView *)view;

@end

@interface SMServerConfigView : NSView

@property (nonatomic, weak) IBOutlet id<SMServerConfigViewDelegate> delegate;

@property (nonatomic, strong) NSString *serverAddressString;
@property (nonatomic, assign) NSUInteger serverPort;//if setted to 0, will use 22 as default
@property (nonatomic, strong) NSString *accountString;
@property (nonatomic, strong) NSString *passwordString;
@property (nonatomic, assign) NSUInteger localPort;//if setted to 0, will use 7070 as default
@property (nonatomic, strong) NSString *remarkString;
@property (nonatomic, assign) BOOL allowConnectionsFromLAN;

@property (nonatomic, assign) BOOL saveButtonEnabled;//Get and read save button enable status
@property (nonatomic, assign) SMServerConfigViewConnectButtonStatus connectButtonStatus;//Connect button status

- (BOOL)becomeFirstResponder;

@end

