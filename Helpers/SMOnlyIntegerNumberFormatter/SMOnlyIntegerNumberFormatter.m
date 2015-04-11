//
//  SMOnlyIntegerNumberFormatter.m
//  SSHMole
//
//  Created by openthread on 4/12/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMOnlyIntegerNumberFormatter.h"
#import <AppKit/AppKit.h>

@implementation SMOnlyIntegerNumberFormatter

- (BOOL)isPartialStringValid:(NSString*)partialString newEditingString:(NSString**)newString errorDescription:(NSString**)error
{
    if([partialString length] == 0)
    {
        return YES;
    }
    
    NSScanner* scanner = [NSScanner scannerWithString:partialString];
    
    if(!([scanner scanInt:0] && [scanner isAtEnd]))
    {
        NSBeep();
        return NO;
    }
    
    return YES;
}

@end
