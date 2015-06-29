//
//  NSObject+OTRuntimeUserInfo.m
//  GPSAlarm
//
//  Created by OpenThread on 10/31/12.
//  Copyright (c) 2012 OpenThread. All rights reserved.
//

#import "NSObject+OTRuntimeUserInfo.h"
#import <objc/runtime.h>

#define kOTRuntimeUserInfoKey       @"OTRuntimeUserInfo"

@implementation NSObject (OTRuntimeUserInfo)

- (id)otRuntimeUserInfo
{
    return objc_getAssociatedObject(self, kOTRuntimeUserInfoKey);
}

- (void)setOtRuntimeUserInfo:(id)otRuntimeUserInfo
{
    objc_setAssociatedObject(self, kOTRuntimeUserInfoKey, otRuntimeUserInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
