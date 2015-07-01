//
//  NSMutableArray+WeakReferences.h
//  NeteaseMusic
//
//  Created by openthread on 6/24/13.
//
//  创建弱引用的MutableArray

#import <Foundation/Foundation.h>

@interface NSMutableArray (WeakReferences)

+ (NSMutableArray *)mutableArrayUsingWeakReferences;

+ (NSMutableArray *)mutableArrayUsingWeakReferencesWithCapacity:(NSUInteger)capacity;

@end
