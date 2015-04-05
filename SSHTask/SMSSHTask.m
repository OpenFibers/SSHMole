//
//  SMSSHTask.m
//  SSHMole
//
//  Created by openthread on 4/4/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMSSHTask.h"

@implementation SMSSHTask
{
    SMServerConfig *_config;
    NSTask *sshTask;
    NSPipe *stdOut;
    NSString *outputContent;
}

- (id)initWithServerConfig:(SMServerConfig *)config
{
    self = [super init];
    if (self)
    {
        _config = config;
    }
    return self;
}

- (void)connect
{
    sshTask = [[NSTask alloc] init];

    stdOut = [NSPipe pipe];
    NSString *helperPath = [[NSBundle mainBundle] pathForResource:@"SSHCommand" ofType:@"sh"];
    
    NSString *argumentString = [_config sshCommandString];
    NSArray *args = [NSArray arrayWithObjects:argumentString, _config.password, nil];
    
    outputContent	= @"";
    
    [sshTask setLaunchPath:helperPath];
    [sshTask setArguments:args];
    
    [sshTask setStandardOutput:stdOut];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleProcessusExecution:)
                                                 name:NSFileHandleReadCompletionNotification
                                               object:[[sshTask standardOutput] fileHandleForReading]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(listernerForSSHTunnelDown:)
                                                 name:NSTaskDidTerminateNotification
                                               object:sshTask];
    
    [[stdOut fileHandleForReading] readInBackgroundAndNotify];
    [self setConnectionInProgress:YES];
    
    [sshTask launch];
}

- (void)disconnect
{
    if ([sshTask isRunning])
    {
        [sshTask terminate];
    }
    sshTask = nil;
}

- (void) handleProcessusExecution:(NSNotification *) aNotification
{
    NSData		*data;
    NSPredicate *checkError;
    NSPredicate *checkWrongPass;
    NSPredicate *checkConnected;
    NSPredicate *checkRefused;
    NSPredicate *checkPort;
    NSPredicate *checkLoggedIn;
    
    data = [[aNotification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    
    outputContent	= [outputContent stringByAppendingString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    checkError		= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'CONNECTION_ERROR'"];
    checkWrongPass	= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'WRONG_PASSWORD'"];
    checkConnected	= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'CONNECTED'"];
    checkRefused	= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'CONNECTION_REFUSED'"];
    checkPort		= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'Could not request local forwarding'"];
    checkLoggedIn   = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'Last login:'"]; // This is for if there is a pub/priv key set up
    
    
    if ([data length])
    {
        if ([checkError evaluateWithObject:outputContent] == YES)
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadCompletionNotification object:[stdOut fileHandleForReading]];
            
            [self setConnected:NO];
            [self setConnectionInProgress:NO];
            [sshTask terminate];
        }
        else if ([checkWrongPass evaluateWithObject:outputContent] == YES)
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadCompletionNotification object:[stdOut fileHandleForReading]];
            [self setConnected:NO];
            [self setConnectionInProgress:NO];
            [sshTask terminate];
        }
        else if ([checkRefused evaluateWithObject:outputContent] == YES)
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadCompletionNotification object:[stdOut fileHandleForReading]];
            [self setConnected:NO];
            [self setConnectionInProgress:NO];
            [sshTask terminate];
        }
        else if ([checkPort evaluateWithObject:outputContent] == YES)
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadCompletionNotification object:[stdOut fileHandleForReading]];
            [self setConnected:NO];
            [self setConnectionInProgress:NO];
            [sshTask terminate];
        }
        else if ([checkConnected evaluateWithObject:outputContent] == YES || [checkLoggedIn evaluateWithObject:outputContent] == YES)
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadCompletionNotification object:[stdOut fileHandleForReading]];
            [self setConnected:YES];
            [self setConnectionInProgress:NO];
        }
        else
        {
            [[stdOut fileHandleForReading] readInBackgroundAndNotify];
        }
        
        data = nil;
        checkError = nil;
        checkWrongPass = nil;
        checkConnected = nil;
        checkPort = nil;
    }
}

- (void) listernerForSSHTunnelDown:(NSNotification *)notification
{	
    [[stdOut fileHandleForReading] closeFile];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSTaskDidTerminateNotification object:sshTask];
    [self setConnected:NO];
    [self setConnectionInProgress:NO];
}

@end
