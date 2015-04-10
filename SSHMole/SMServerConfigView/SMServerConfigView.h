//
//  ViewController.h
//  SSHMole
//
//  Created by openthread on 4/4/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@class SMServerConfigView;

@protocol SMServerConfigViewDelegate <NSObject>

- (void)serverConfigView:(SMServerConfigView *)connectButtonTouched;

@end

@interface SMServerConfigView : NSView

@property (nonatomic, weak) IBOutlet id<SMServerConfigViewDelegate> delegate;

@end

