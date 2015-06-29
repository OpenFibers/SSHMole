//
//  SMServerConfigSplitController.h
//  SSHMole
//
//  Created by openthread on 4/5/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class SMServerConfig;

@interface SMServerConfigSplitController : NSViewController

- (void)connectServerConfig:(SMServerConfig *)config;

@end
