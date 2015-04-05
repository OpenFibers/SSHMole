//
//  ViewController.m
//  SSHMole
//
//  Created by openthread on 4/4/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMServerConfigView.h"
#import "SMServerConfigStorage.h"
#import "NSView+Vibrancy.h"

@implementation SMServerConfigView

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        NSArray *array = nil;
        [[NSBundle mainBundle] loadNibNamed:@"ServerConfigView" owner:self topLevelObjects:&array];
        for (id subObject in array)
        {
            if ([subObject isKindOfClass:[NSView class]])
            {
                [self addSubview:subObject];
                break;
            }
        }
    }
    return self;
}

- (void)addServerConfig
{
    SMServerConfig *config = [[SMServerConfig alloc] init];
    config.serverName = @"123123";
    config.account = @"root";
    config.password = @"123123";
    config.serverPort = 22;
    config.localPort = 7070;
    [[SMServerConfigStorage defaultStorage] addConfig:config];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor whiteColor] setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
}

@end
