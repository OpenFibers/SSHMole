//
//  SMLaunchHelper.m
//  SSHMole
//
//  Created by openthread on 7/5/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMLaunchManager.h"

@implementation SMLaunchManager
{
    BOOL _isAppLaunchsAtUserLogin;
}

+ (instancetype)defaultManager
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _isAppLaunchsAtUserLogin = [SMLaunchManager isAppLaunchsAtUserLogin];
    }
    return self;
}

- (void)addAppAsLoginItem
{
    [self deleteAppFromLoginItem];
    
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];
    
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems,
                                                            NULL);
    if (loginItems)
    {
        LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,
                                                                     kLSSharedFileListItemLast,
                                                                     NULL,
                                                                     NULL,
                                                                     url,
                                                                     NULL,
                                                                     NULL);
        if (item)
        {
            CFRelease(item);
        }
        CFRelease(loginItems);
    }
}

- (void)deleteAppFromLoginItem
{
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems,
                                                            NULL);
    
    if (loginItems)
    {
        UInt32 seedValue;
        NSArray  *loginItemsArray = (NSArray *)CFBridgingRelease(LSSharedFileListCopySnapshot(loginItems, &seedValue));
        for(int i = 0 ; i< [loginItemsArray count]; i++)
        {
            LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)[loginItemsArray
                                                                        objectAtIndex:i];
            //Resolve the item with URL
            NSURL *url = CFBridgingRelease(LSSharedFileListItemCopyResolvedURL(itemRef, 0, NULL));
            if (url)
            {
                NSString * urlPath = [url path];
                if ([urlPath compare:appPath] == NSOrderedSame)
                {
                    LSSharedFileListItemRemove(loginItems,itemRef);
                }
            }
        }
    }
}

+ (BOOL)isAppLaunchsAtUserLogin
{
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems,
                                                            NULL);
    
    if (loginItems)
    {
        UInt32 seedValue;
        NSArray  *loginItemsArray = (NSArray *)CFBridgingRelease(LSSharedFileListCopySnapshot(loginItems, &seedValue));
        for(int i = 0 ; i< [loginItemsArray count]; i++)
        {
            LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)[loginItemsArray
                                                                                 objectAtIndex:i];
            //Resolve the item with URL
            NSURL *url = CFBridgingRelease(LSSharedFileListItemCopyResolvedURL(itemRef, 0, NULL));
            if (url)
            {
                NSString * urlPath = [url path];
                if ([urlPath compare:appPath] == NSOrderedSame)
                {
                    return YES;
                }
            }
        }
    }
    
    return NO;
}


@end
