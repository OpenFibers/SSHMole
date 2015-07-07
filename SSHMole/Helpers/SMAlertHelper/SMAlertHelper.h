//
//  SMAlertHelper.h
//  SSHMole
//
//  Created by 史江浩 on 7/7/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMAlertHelper : NSObject

+ (void)showAlertWithOKButtonAndString:(NSString *)string;

+ (void)showAlertForErrorDomain:(NSError *)error;

+ (void)showAlertForErrorDomainAndDescription:(NSError *)error;

@end
