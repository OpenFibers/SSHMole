//
//  SMSandboxPath.m
//  SSHMole
//
//  Created by openthread on 6/22/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMSandboxPath.h"

@implementation SMSandboxPath

+ (NSString *)systemConfigrationHelperPath
{
    static NSString *helperPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helperPath = [[self sandboxPath] stringByAppendingPathComponent:@"Documents/SSHMoleSystemConfigurationHelper"];
    });
    return helperPath;
}

+ (NSString *)pacPathForName:(NSString *)name
{
    static NSString *helperPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helperPath = [[self sandboxPath] stringByAppendingPathComponent:@"Documents/PAC"];
        helperPath = [helperPath stringByAppendingPathComponent:name];
    });
    return helperPath;
}

+ (NSString *)sandboxPath
{
    static NSString *sandboxPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *homeDir = NSHomeDirectory();
        sandboxPath = [homeDir stringByAppendingPathComponent:@"/Library/Containers/openthread.SSHMole/Data/"];
    });
    return sandboxPath;
}

@end
