//
//  ViewController.m
//  SSHMole
//
//  Created by openthread on 4/4/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMServerConfigView.h"
#import "SMServerConfig.h"

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

- (id)initWithCoder:(NSCoder *)aDecoder
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
    }
    return self;
}

- (void)setServerConfig:(SMServerConfig *)config
{
    if (!config)//User will add a new config
    {
        [self.serverTextField setStringValue:@""];
        [self.portTextField setStringValue:@""];
        [self.userNameTextField setStringValue:@""];
        [self.passwordTextField setStringValue:@""];
        [self.localPortTextField setStringValue:@""];
        [self.remarkTextField setStringValue:@""];
    }
    else//User will edit current config
    {
        [self.serverTextField setStringValue:config.serverName];
        [self.portTextField setStringValue:[NSString stringWithFormat:@"%tu", config.serverPort]];
        [self.userNameTextField setStringValue:config.account];
        [self.passwordTextField setStringValue:config.password];
        [self.localPortTextField setStringValue:[NSString stringWithFormat:@"%tu", config.localPort]];
        [self.remarkTextField setStringValue:config.remark];
    }
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

- (IBAction)connectButtonTouched:(NSButton *)sender
{
    [self.delegate serverConfigViewConnectButtonTouched:self];
}

@end
