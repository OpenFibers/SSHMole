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

- (void)beginPacServerWithData:(NSData *)data path:(NSString *)path;

- (void)stopPacServer;

@end
