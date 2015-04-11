//
//  ViewController.m
//  SSHMole
//
//  Created by openthread on 4/4/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMServerConfigView.h"
#import "SMOnlyIntegerNumberFormatter.h"

@interface SMServerConfigView ()

@property (weak) IBOutlet NSTextField *serverAddressTextField;
@property (weak) IBOutlet NSTextField *serverPortTextField;
@property (weak) IBOutlet NSTextField *accountTextField;
@property (weak) IBOutlet NSSecureTextField *passwordTextField;
@property (weak) IBOutlet NSTextField *localPortTextField;
@property (weak) IBOutlet NSTextField *remarkTextField;
@property (weak) IBOutlet NSButton *connectButton;
@property (weak) IBOutlet NSButton *saveButton;
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
        
        //Only number available in port text fields
        SMOnlyIntegerNumberFormatter *formatter = [[SMOnlyIntegerNumberFormatter alloc] init];
        [self.serverPortTextField setFormatter:formatter];
        [self.localPortTextField setFormatter:formatter];
    }
    return self;
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

#pragma mark - Become first responder

- (BOOL)becomeFirstResponder
{
    if (self.passwordString.length == 0)
    {
        return [self.serverAddressTextField becomeFirstResponder];
    }
    else if (self.remarkString.length == 0)
    {
        return [self.remarkTextField becomeFirstResponder];
    }
    else if (self.accountString.length == 0)
    {
        return [self.accountTextField becomeFirstResponder];
    }
    else if (self.passwordString.length == 0)
    {
        return [self.passwordTextField becomeFirstResponder];
    }
    else
    {
        return [self.connectButton becomeFirstResponder];
    }
}

#pragma mark - Public methods to access input values

- (NSString *)serverAddressString
{
    return [self.serverAddressTextField stringValue];
}

- (void)setServerAddressString:(NSString *)serverAddressString
{
    [self.serverAddressTextField setStringValue:serverAddressString];
}

- (NSUInteger)serverPort
{
    NSUInteger serverPort = (NSUInteger)[[self.serverPortTextField stringValue] integerValue];
    return serverPort;
}

- (void)setServerPort:(NSUInteger)serverPort
{
    if (serverPort == 0)//default server port
    {
        serverPort = 22;
    }
    NSString *stringValue = [NSString stringWithFormat:@"%tu", serverPort];
    [self.serverPortTextField setStringValue:stringValue];
}

- (NSString *)accountString
{
    return [self.accountTextField stringValue];
}

- (void)setAccountString:(NSString *)accountString
{
    [self.accountTextField setStringValue:accountString];
}

- (NSString *)passwordString
{
    return [self.passwordTextField stringValue];
}

- (void)setPasswordString:(NSString *)passwordString
{
    [self.passwordTextField setStringValue:passwordString];
}

- (NSUInteger)localPort
{
    return (NSUInteger)[[self.localPortTextField stringValue] integerValue];
}

- (void)setLocalPort:(NSUInteger)localPort
{
    if (localPort == 0)
    {
        localPort = 7070;//default local port
    }
    NSString *stringValue = [NSString stringWithFormat:@"%tu", localPort];
    [self.localPortTextField setStringValue:stringValue];
}

- (NSString *)remarkString
{
    return [self.remarkTextField stringValue];
}

- (void)setRemarkString:(NSString *)remarkString
{
    [self.remarkTextField setStringValue:remarkString];
}

#pragma mark - Button actions

- (IBAction)connectButtonTouched:(NSButton *)sender
{
    [self.delegate serverConfigViewConnectButtonTouched:self];
}

- (IBAction)saveButtonTouched:(NSButton *)sender
{
    [self.delegate serverConfigViewSaveButtonTouched:self];
}

@end
