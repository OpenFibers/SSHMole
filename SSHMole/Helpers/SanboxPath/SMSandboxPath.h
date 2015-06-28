//
//  SMSandboxPath.h
//  SSHMole
//
//  Created by openthread on 6/22/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMSandboxPath : NSObject

/**
 *  Path for system configuration helper
 *
 *  @return Path for system configuration helper
 */
+ (NSString *)systemConfigrationHelperPath;

/**
 *  PAC files folder path
 *
 *  @return PAC files folder path
 */
+ (NSString *)pacFolderPath;

/**
 *  Pac file path for pac file name
 *
 *  @param name Pac file name
 *
 *  @return Pac file path for pac file name
 */
+ (NSString *)pacPathForName:(NSString *)name;

@end
