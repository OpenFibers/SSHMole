//
//  SMWebServerManager.h
//  SSHMole
//
//  Created by openthread on 6/22/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SMWebServerManager : NSObject

+ (instancetype)defaultManager;

/**
 *  开启pac server
 *
 *  @param port 端口
 */
- (BOOL)beginPacServerWithPort:(NSUInteger)port error:(NSError **)error;

- (void)stopPacServer;

/**
 *  给server 增加 handler
 *
 *  @param data pac的data
 *  @param path web server 路径。system configuration helper中设置的是“/proxy.pac”
 */
- (void)addHandlerForPath:(NSString *)path data:(NSData *)data;

- (void)removeAllHandlers;

@end
