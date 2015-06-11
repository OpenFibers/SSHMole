//
//  NSView+Vibrancy.h
//  SSHMole
//
//  Created by openthread on 4/5/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (Vibrancy)

//Returns NSVisualEffectView
- (instancetype)insertVibrancyViewBlendingMode:(NSVisualEffectBlendingMode)mode;

@end
