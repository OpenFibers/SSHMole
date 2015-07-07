//
//  SMAlertHelper.m
//  SSHMole
//
//  Created by 史江浩 on 7/7/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMAlertHelper.h"
#import <AppKit/AppKit.h>

@implementation SMAlertHelper

+ (void)showAlertWithOKButtonAndString:(NSString *)string
{
    if (![NSThread isMainThread])
    {
        id classObject = self;
        [classObject performSelectorOnMainThread:@selector(showAlertWithOKButtonAndString:) withObject:string waitUntilDone:NO];
        return;
    }
    NSAlert *alert = [[NSAlert alloc]init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:string];
    [alert runModal];
}

+ (void)showAlertForErrorDomain:(NSError *)error
{
    [self showAlertWithOKButtonAndString:error.domain];
}

+ (void)showAlertForErrorDomainAndDescription:(NSError *)error
{
    NSString *errorString = [NSString stringWithFormat:@"%@\n%@", error.domain, error.localizedDescription];
    [self showAlertWithOKButtonAndString:errorString];
}

@end
