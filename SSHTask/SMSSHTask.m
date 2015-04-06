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
    NSTask *_sshTask;
    NSPipe *_stdOut;
    NSMutableString *_outputContent;
}

- (void)setConnected:(BOOL)connected
{
    _connected = connected;
}

- (void)setConnectionInProgress:(BOOL)connectionInProgress
{
    _connectionInProgress = connectionInProgress;
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

- (void)dealloc
{
    [self disconnectWithoutCallback];
}

- (void)connect
{
    //init output string
    _outputContent = nil;
    _outputContent = [NSMutableString string];
    
    //init pipe
    _stdOut = [NSPipe pipe];

    //init task
    if (_sshTask)
    {
        [_sshTask terminate];
        _sshTask = nil;
    }
    _sshTask = [[NSTask alloc] init];

    //setup task
    NSString *helperPath = [[NSBundle mainBundle] pathForResource:@"SSHCommand" ofType:@"sh"];
    NSString *argumentString = [_config sshCommandString];
    NSArray *args = [NSArray arrayWithObjects:argumentString, _config.password, nil];
    [_sshTask setLaunchPath:helperPath];
    [_sshTask setArguments:args];
    [_sshTask setStandardOutput:_stdOut];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleProcessusExecution:)
                                                 name:NSFileHandleReadCompletionNotification
                                               object:[[_sshTask standardOutput] fileHandleForReading]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(listernerForSSHTunnelDown:)
                                                 name:NSTaskDidTerminateNotification
                                               object:_sshTask];
    
    [[_stdOut fileHandleForReading] readInBackgroundAndNotify];
    [self setConnectionInProgress:YES];
    
    [_sshTask launch];
}

- (void)disconnect
{
    [self disconnectWithoutCallback];
}

- (void)disconnectWithoutCallback
{
    if ([_sshTask isRunning])
    {
        [_sshTask terminate];
    }
    _sshTask = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setConnected:NO];
    [self setConnectionInProgress:NO];
}

- (void)handleProcessusExecution:(NSNotification *)aNotification
{
    //Predicate to check states
    static NSPredicate *checkError;
    static NSPredicate *checkWrongPass;
    static NSPredicate *checkNoRoute;
    static NSPredicate *checkConnected;
    static NSPredicate *checkRefused;
    static NSPredicate *checkPort;
    static NSPredicate *checkLoggedIn;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        checkError		= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'CONNECTION_ERROR'"];
        checkWrongPass	= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'WRONG_PASSWORD'"];
        checkNoRoute	= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'NO_ROUTE_TO_HOST'"];
        checkConnected	= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'CONNECTED'"];
        checkRefused	= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'CONNECTION_REFUSED'"];
        checkPort		= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'Could not request local forwarding'"];
        checkLoggedIn   = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'Last login:'"]; // This is for if there is a pub/priv key set up
    });
    
    //Get last read data
    NSData *data = [[aNotification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    [_outputContent appendString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    
    if ([data length])
    {
        if ([checkError evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutCallback];
        }
        else if ([checkWrongPass evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutCallback];
        }
        else if ([checkNoRoute evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutCallback];
        }
        else if ([checkRefused evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutCallback];
        }
        else if ([checkPort evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutCallback];
        }
        else if ([checkConnected evaluateWithObject:_outputContent] == YES || [checkLoggedIn evaluateWithObject:_outputContent] == YES)
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadCompletionNotification object:[_stdOut fileHandleForReading]];
            [self setConnected:YES];
            [self setConnectionInProgress:NO];
        }
        else
        {
            [[_stdOut fileHandleForReading] readInBackgroundAndNotify];
        }
    }
}

- (void)listernerForSSHTunnelDown:(NSNotification *)notification
{	
    [[_stdOut fileHandleForReading] closeFile];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSTaskDidTerminateNotification object:_sshTask];
    [self setConnected:NO];
    [self setConnectionInProgress:NO];
}

@end
