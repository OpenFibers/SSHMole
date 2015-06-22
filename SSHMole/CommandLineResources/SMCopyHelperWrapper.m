//
//  SMCopyHelperWrapper.m
//  SSHMole
//
//  Created by 史江浩 on 6/11/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMCopyHelperWrapper.h"
#import "SMSandboxPath.h"

@implementation SMCopyHelperWrapper

+ (NSString *)helperPath
{
    return [SMSandboxPath systemConfigrationHelperPath];
}

+ (BOOL)installHelperIfNotExist
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[self helperPath]])
    {
        NSString *installerPath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"CopyHelperCommand.sh"];
        NSDictionary *error;
        NSString *script = [NSString stringWithFormat:@"do shell script \"bash %@\" with administrator privileges", installerPath];
        NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script];
        NSAppleEventDescriptor *descriptor = [appleScript executeAndReturnError:&error];
        if (descriptor && !error)
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    return YES;
}

@end
