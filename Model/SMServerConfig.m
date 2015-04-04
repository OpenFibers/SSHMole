//
//  SMServerConfig.m
//  SSHMole
//
//  Created by openthread on 4/4/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMServerConfig.h"
#import "SMUUIDHelper.h"

@implementation SMServerConfig

- (id)init
{
    self = [super init];
    if (self)
    {
        _configID = [SMUUIDHelper generateRandomUUIDString];
    }
    return self;
}

@end
