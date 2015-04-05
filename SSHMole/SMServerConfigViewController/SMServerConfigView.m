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
#import "SMSSHTask.h"

@interface SMServerConfigView ()

@property (weak) IBOutlet NSTextField *serverTextField;
@property (weak) IBOutlet NSTextField *portTextField;
@property (weak) IBOutlet NSTextField *userNameTextField;
@property (weak) IBOutlet NSTextField *passwordTextField;
@property (weak) IBOutlet NSTextField *localPortTextField;
@property (weak) IBOutlet NSTextField *remarkTextField;
@property (weak) IBOutlet NSButton *connectButton;
@end

@implementation SMServerConfigView
{
    NSView *_innerXibView;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        NSArray *array = nil;
        [[NSBundle mainBundle] loadNibNamed:@"ServerConfigView" owner:self topLevelObjects:&array];
        for (NSView *subObject in array)
        {
            if ([subObject isKindOfClass:[NSView class]])
            {
                _innerXibView = subObject;
                _innerXibView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
                [self addSubview:subObject];
                break;
            }
        }
        
        [self addServerConfig];
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
    
    SMSSHTask *task = [[SMSSHTask alloc] initWithServerConfig:config];
    [task connect];
}

- (void)layout
{
    _innerXibView.frame = self.bounds;
    [super layout];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor whiteColor] setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
}

@end
