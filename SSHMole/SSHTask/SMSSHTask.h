//
//  SMSSHTask.h
//  SSHMole
//
//  Created by openthread on 4/4/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMServerConfig.h"

typedef NS_ENUM(NSUInteger, SMSSHTaskStatus) {
    SMSSHTaskStatusConnecting,
    SMSSHTaskStatusConnected,
    SMSSHTaskStatusErrorOccured,
    SMSSHTaskStatusDisconnected,
};

typedef NS_ENUM(NSUInteger, SMSSHTaskErrorCode) {
    SMSSHTaskErrorCodeConfigError,
    SMSSHTaskErrorCodeGeneralError,
    SMSSHTaskErrorCodeRefused,
    SMSSHTaskErrorCodeHostNotFound,
    SMSSHTaskErrorCodeLocalPortCouldNotForward,
    SMSSHTaskErrorCodeBadLocalPort,
    SMSSHTaskErrorCodePrivilegedLocalPortUnavailable,
    SMSSHTaskErrorCodeLocalPortUsed,
    SMSSHTaskErrorCodeBadRemotePort,
    SMSSHTaskErrorCodeRemotePortClosedByServer,
    SMSSHTaskErrorCodeSyntaxError,
    SMSSHTaskErrorCodeWrongPassword,
    SMSSHTaskErrorCodeNSTaskException,
};

@interface SMSSHTask : NSObject

@property (nonatomic, readonly) BOOL connectionInProgress;
@property (nonatomic, readonly) BOOL connected;
@property (nonatomic, readonly) SMSSHTaskStatus currentStatus;
@property (nonatomic, readonly) SMServerConfig *config;
@property (nonatomic, assign) BOOL shouldLogTaskStdOut;

- (id)initWithServerConfig:(SMServerConfig *)config;

- (void)connect:(void(^)(SMSSHTaskStatus status, NSError *error))callback;

- (void)disconnect;

@end
