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

FOUNDATION_EXTERN const NSInteger SMSSHTaskDisconnectForAppTerminationErrorCode;

@interface SMSSHTask : NSObject

@property (nonatomic, readonly) BOOL connectionInProgress;
@property (nonatomic, readonly) BOOL connected;
@property (nonatomic, readonly) SMSSHTaskStatus currentStatus;
@property (nonatomic, readonly) SMServerConfig *config;
@property (nonatomic, assign) BOOL shouldLogTaskStdOut;

- (id)initWithServerConfig:(SMServerConfig *)config;

/**
 *  Set or clear callback of connection status.
 *  失败时， SMSSHTaskStatusErrorOccured 和 SMSSHTaskStatusDisconnected 并无时序保证。回调顺序看系统心情。
 */
@property (nonatomic, copy) void(^callback)(SMSSHTaskStatus status, NSError *error);

/**
 *  Connect task
 */
- (void)connect;

/**
 *  Disconnect task
 */
- (void)disconnect;

/**
 *  Disconnect for app termination. An error will raise with domain "App Terminated" and code SMSSHTaskDisconnectForAppTerminationErrorCode(1001) for callback.
 */
- (void)disconnectForAppTermination;

@end
