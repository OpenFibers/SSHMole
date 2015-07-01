//
//  NSMutableArray+WeakReferences.m
//  NeteaseMusic
//
//  Created by openthread on 6/24/13.
//
//

#import "NSMutableArray+WeakReferences.h"

@implementation NSMutableArray (WeakReferences)

+ (NSMutableArray *)mutableArrayUsingWeakReferences
{
    return [self mutableArrayUsingWeakReferencesWithCapacity:0];
}

+ (NSMutableArray *)mutableArrayUsingWeakReferencesWithCapacity:(NSUInteger)capacity
{
    CFArrayCallBacks callbacks = {0, NULL, NULL, CFCopyDescription, CFEqual};
    CFMutableArrayRef mutableArrayRef = CFArrayCreateMutable(0, capacity, &callbacks);
    return (__bridge_transfer NSMutableArray *)mutableArrayRef;
}

@end
