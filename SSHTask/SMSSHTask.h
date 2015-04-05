//
//  SMSSHTask.h
//  SSHMole
//
//  Created by openthread on 4/4/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMServerConfig.h"

@interface SMSSHTask : NSObject

@property (nonatomic, assign) BOOL connectionInProgress;
@property (nonatomic, assign) BOOL connected;

- (id)initWithServerConfig:(SMServerConfig *)config;

- (void)connect;

- (void)disconnect;

@end
