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
    static NSPredicate *checkError;
    static NSPredicate *checkRefused;
    
    //host error
    static NSPredicate *checkHost;
    
    //local port error
    static NSPredicate *checkPort;
    static NSPredicate *checkBadLocalForwarding;
    static NSPredicate *checkPrivilegdLocalPorts;
    static NSPredicate *checkLocalPortUsed;
    
    //remote port error
    static NSPredicate *badRemotePort;
    static NSPredicate *remotePortCloseByServer;
    
    //syntax error
    static NSPredicate *syntaxError;
    
    //wrong pass
    static NSPredicate *checkWrongPass;

    //connected or login
    static NSPredicate *checkConnected;
    static NSPredicate *checkLoggedIn;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //error or refused
        checkError = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'CONNECTION_ERROR'"];
        checkRefused = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'CONNECTION_REFUSED'"];
        
        //host error
        checkHost = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'NO_ROUTE_TO_HOST'"];
        
        //forwarding port error
        checkPort = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'Could not request local forwarding'"];
        checkBadLocalForwarding = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'BAD_DYNAMIC_FORWARDING_SPECIFICATION'"];
        checkPrivilegdLocalPorts = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'PRIVILEGED_DYNAMIC_PORTS_UNAVAILABLE'"];
        checkLocalPortUsed = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'DYNAMIC_PORTS_USED'"];
        
        //remote port error
        badRemotePort = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'BAD_REMOTE_PORT'"];
        remotePortCloseByServer = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'REMOTE_PORT_SHUT_DOWN'"];
        
        //syntax error
        syntaxError = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'SSH_SYNTAX_ERROR'"];
        
        //wrong pass check
        checkWrongPass	= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'WRONG_PASSWORD'"];
        
        //success check
        checkConnected	= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'CONNECTED'"];
        checkLoggedIn   = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'Last login:'"]; // This is for if there is a pub/priv key set up
    });
    
    //Get last read data
    NSData *data = [[aNotification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    [_outputContent appendString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    
    if ([data length])
    {
        //error and refused
        if ([checkError evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutCallback];
        }
        else if ([checkRefused evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutCallback];
        }
        //host error
        else if ([checkHost evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutCallback];
        }
        //local port error
        else if ([checkPort evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutCallback];
        }
        else if ([checkBadLocalForwarding evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutCallback];
        }
        else if ([checkPrivilegdLocalPorts evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutCallback];
        }
        else if ([checkLocalPortUsed evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutCallback];
        }
        //remote port error
        else if ([badRemotePort evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutCallback];
        }
        else if ([remotePortCloseByServer evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutCallback];
        }
        //syntax error
        else if ([syntaxError evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutCallback];
        }
        //wrong password
        else if ([checkWrongPass evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutCallback];
        }
        //connected
        else if ([checkConnected evaluateWithObject:_outputContent] == YES || [checkLoggedIn evaluateWithObject:_outputContent] == YES)
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
