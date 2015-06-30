//
//  SMStatusBarUserDefaultsManager.h
//  SSHMole
//
//  Created by openthread on 6/30/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMStatusBarController.h"

@interface SMStatusBarUserDefaultsManager : NSObject

+ (instancetype)defaultManager;

@property (nonatomic, assign) SMStatusBarControllerProxyMode lastProxyMode;
@property (nonatomic, strong) NSString *lastConnectingConfigIdentifier;

@end
