//
//  SMLaunchHelper.h
//  SSHMole
//
//  Created by openthread on 7/5/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMLaunchManager : NSObject

+ (instancetype)defaultManager;

@property (nonatomic, assign) BOOL appLaunchesAtUserLogin;

@end
