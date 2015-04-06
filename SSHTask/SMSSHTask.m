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
    //check config available
    if (!_config || ![_config ableToConnect])
    {
#warning puts error
        return;
    }
    
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
    static NSPredicate *errorPredicate;
    static NSPredicate *refusedPredicate;
    
    //host error
    static NSPredicate *checkHostPredicate;
    
    //local port error
    static NSPredicate *localPortCouldNotForwardPredicate;
    static NSPredicate *badLocalForwardingPredicate;
    static NSPredicate *privilegdLocalPortUnavailablePredicate;
    static NSPredicate *localPortUsedPredicate;
    
    //remote port error
    static NSPredicate *badRemotePortPredicate;
    static NSPredicate *remotePortCloseByServerPredicate;
    
    //syntax error
    static NSPredicate *syntaxErrorPredicate;
    
    //wrong pass
    static NSPredicate *wrongPasswordPredicate;

    //connected or login
    static NSPredicate *connectedPredicate;
    static NSPredicate *loginPredicate;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //error or refused
        errorPredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'CONNECTION_ERROR'"];
        refusedPredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'CONNECTION_REFUSED'"];
        
        //host error
        checkHostPredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'NO_ROUTE_TO_HOST'"];
        
        //forwarding port error
        localPortCouldNotForwardPredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'Could not request local forwarding'"];
        badLocalForwardingPredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'BAD_DYNAMIC_FORWARDING_SPECIFICATION'"];
        privilegdLocalPortUnavailablePredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'PRIVILEGED_DYNAMIC_PORTS_UNAVAILABLE'"];
        localPortUsedPredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'DYNAMIC_PORTS_USED'"];
        
        //remote port error
        badRemotePortPredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'BAD_REMOTE_PORT'"];
        remotePortCloseByServerPredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'REMOTE_PORT_SHUT_DOWN'"];
        
        //syntax error
        syntaxErrorPredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'SSH_SYNTAX_ERROR'"];
        
        //wrong pass check
        wrongPasswordPredicate	= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'WRONG_PASSWORD'"];
        
        //success check
        connectedPredicate	= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'CONNECTED'"];
        loginPredicate   = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'Last login:'"]; // This is for if there is a pub/priv key set up
    });
    
    //Get last read data
    NSData *data = [[aNotification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    [_outputContent appendString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    
    if ([data length])
    {
        //error and refused
        if ([errorPredicate evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutCallback];
        }
        else if ([refusedPredicate evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutCallback];
        }
        //host error
        else if ([checkHostPredicate evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutCallback];
        }
        //local port error
        else if ([localPortCouldNotForwardPredicate evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutCallback];
        }
        else if ([badLocalForwardingPredicate evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutCallback];
        }
        else if ([privilegdLocalPortUnavailablePredicate evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutCallback];
        }
        else if ([localPortUsedPredicate evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutCallback];
        }
        //remote port error
        else if ([badRemotePortPredicate evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutCallback];
        }
        else if ([remotePortCloseByServerPredicate evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutCallback];
        }
        //syntax error
        else if ([syntaxErrorPredicate evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutCallback];
        }
        //wrong password
        else if ([wrongPasswordPredicate evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutCallback];
        }
        //connected
        else if ([connectedPredicate evaluateWithObject:_outputContent] == YES || [loginPredicate evaluateWithObject:_outputContent] == YES)
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadCompletionNotification object:[_stdOut fileHandleForReading]];
            [self setConnected:YES];
            [self setConnectionInProgress:NO];
        }
        //unfinished reading
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
