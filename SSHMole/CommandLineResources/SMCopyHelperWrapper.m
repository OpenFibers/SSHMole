//
//  SMCopyHelperWrapper.m
//  SSHMole
//
//  Created by 史江浩 on 6/11/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMCopyHelperWrapper.h"

static NSString *const CopyHelperPath = @"~/Library/Containers/openthread.SSHMole/SSHMoleSystemConfigurationHelper";

@implementation SMCopyHelperWrapper

+ (BOOL)installHelper
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:CopyHelperPath])
    {
        NSString *helperPath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"install_helper.sh"];
        NSLog(@"run install script: %@", helperPath);
        NSDictionary *error;
        NSString *script = [NSString stringWithFormat:@"do shell script \"bash %@\" with administrator privileges", helperPath];
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
