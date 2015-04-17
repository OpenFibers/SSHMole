//
//  SMSSHTask.m
//  SSHMole
//
//  Created by openthread on 4/4/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMSSHTask.h"

#warning separate connect and set callback

@implementation SMSSHTask
{
    SMServerConfig *_config;
    void(^_callback)(SMSSHTaskStatus status, NSError *error);
    NSTask *_sshTask;
    NSPipe *_stdOut;
    NSMutableString *_outputContent;
}

- (SMServerConfig *)config
{
    return _config;
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
    [self disconnect];
}

- (void)connect:(void(^)(SMSSHTaskStatus status, NSError *error))callback
{
    //store callback block
    _callback = [callback copy];
    
    //check config available
    if (!_config || ![_config ableToConnect])
    {
        NSError *error = [[NSError alloc] initWithDomain:@"SSH config error" code:SMSSHTaskErrorCodeConfigError userInfo:nil];
        [self callbackWithStatus:SMSSHTaskStatusErrorOccured error:error];
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
    
    [self callbackWithStatus:SMSSHTaskStatusConnecting error:nil];
}

- (void)disconnect
{
    [self disconnectWithoutResetCallback];
    _callback = nil;
}

- (void)disconnectWithoutResetCallback
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
    static NSPredicate *hostNotFoundPredicate;
    
    //local port error
    static NSPredicate *localPortCouldNotForwardPredicate;
    static NSPredicate *badLocalForwardingPredicate;
    static NSPredicate *privilegedLocalPortUnavailablePredicate;
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
        hostNotFoundPredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'NO_ROUTE_TO_HOST'"];
        
        //forwarding port error
        localPortCouldNotForwardPredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'Could not request local forwarding'"];
        badLocalForwardingPredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'BAD_DYNAMIC_FORWARDING_SPECIFICATION'"];
        privilegedLocalPortUnavailablePredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'PRIVILEGED_DYNAMIC_PORTS_UNAVAILABLE'"];
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
    NSString *incomingString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [_outputContent appendString:incomingString];
    if (self.shouldLogTaskStdOut)
    {
        NSLog(@"%@", incomingString);
    }
    
    if ([data length])
    {
        //error and refused
        if ([errorPredicate evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutResetCallback];
            NSError *error = [NSError errorWithDomain:@"SSH connection error occurred"
                                                 code:SMSSHTaskErrorCodeGeneralError
                                             userInfo:nil];
            [self callbackWithStatus:SMSSHTaskStatusErrorOccured error:error];
        }
        else if ([refusedPredicate evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutResetCallback];
            NSError *error = [NSError errorWithDomain:@"SSH connection refused"
                                                 code:SMSSHTaskErrorCodeRefused
                                             userInfo:nil];
            [self callbackWithStatus:SMSSHTaskStatusErrorOccured error:error];
        }
        //host error
        else if ([hostNotFoundPredicate evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutResetCallback];
            NSError *error = [NSError errorWithDomain:@"Host not found"
                                                 code:SMSSHTaskErrorCodeHostNotFound
                                             userInfo:nil];
            [self callbackWithStatus:SMSSHTaskStatusErrorOccured error:error];
        }
        //local port error
        else if ([localPortCouldNotForwardPredicate evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutResetCallback];
            NSError *error = [NSError errorWithDomain:@"Local port could not forward"
                                                 code:SMSSHTaskErrorCodeLocalPortCouldNotForward
                                             userInfo:nil];
            [self callbackWithStatus:SMSSHTaskStatusErrorOccured error:error];
        }
        else if ([badLocalForwardingPredicate evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutResetCallback];
            NSError *error = [NSError errorWithDomain:@"Bad local port"
                                                 code:SMSSHTaskErrorCodeBadLocalPort
                                             userInfo:nil];
            [self callbackWithStatus:SMSSHTaskStatusErrorOccured error:error];
        }
        else if ([privilegedLocalPortUnavailablePredicate evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutResetCallback];
            NSError *error = [NSError errorWithDomain:@"Privileged local port unavailable"
                                                 code:SMSSHTaskErrorCodePrivilegedLocalPortUnavailable
                                             userInfo:nil];
            [self callbackWithStatus:SMSSHTaskStatusErrorOccured error:error];
        }
        else if ([localPortUsedPredicate evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutResetCallback];
            NSError *error = [NSError errorWithDomain:@"Local port used"
                                                 code:SMSSHTaskErrorCodeLocalPortUsed
                                             userInfo:nil];
            [self callbackWithStatus:SMSSHTaskStatusErrorOccured error:error];
        }
        //remote port error
        else if ([badRemotePortPredicate evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutResetCallback];
            NSError *error = [NSError errorWithDomain:@"Bad remote port"
                                                 code:SMSSHTaskErrorCodeBadRemotePort
                                             userInfo:nil];
            [self callbackWithStatus:SMSSHTaskStatusErrorOccured error:error];
        }
        else if ([remotePortCloseByServerPredicate evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutResetCallback];
            NSError *error = [NSError errorWithDomain:@"Remote port closed by server"
                                                 code:SMSSHTaskErrorCodeRemotePortClosedByServer
                                             userInfo:nil];
            [self callbackWithStatus:SMSSHTaskStatusErrorOccured error:error];
        }
        //syntax error
        else if ([syntaxErrorPredicate evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutResetCallback];
            NSError *error = [NSError errorWithDomain:@"Syntax Error"
                                                 code:SMSSHTaskErrorCodeSyntaxError
                                             userInfo:nil];
            [self callbackWithStatus:SMSSHTaskStatusErrorOccured error:error];
        }
        //wrong password
        else if ([wrongPasswordPredicate evaluateWithObject:_outputContent] == YES)
        {
            [self disconnectWithoutResetCallback];
            NSError *error = [NSError errorWithDomain:@"Wrong Password"
                                                 code:SMSSHTaskErrorCodeWrongPassword
                                             userInfo:nil];
            [self callbackWithStatus:SMSSHTaskStatusErrorOccured error:error];
        }
        //connected
        else if ([connectedPredicate evaluateWithObject:_outputContent] == YES || [loginPredicate evaluateWithObject:_outputContent] == YES)
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadCompletionNotification object:[_stdOut fileHandleForReading]];
            [self setConnected:YES];
            [self setConnectionInProgress:NO];
            [self callbackWithStatus:SMSSHTaskStatusConnected error:nil];

        }
        //unfinished reading
        else
        {
            @try
            {
                [[_stdOut fileHandleForReading] readInBackgroundAndNotify];
            }
            @catch (NSException *exception)
            {
                NSError *error = [[NSError alloc] initWithDomain:@"File handle reading excetion" code:SMSSHTaskErrorCodeNSTaskException userInfo:nil];
                [self callbackWithStatus:SMSSHTaskStatusErrorOccured error:error];
                [self disconnect];
            }
        }
    }
}

- (void)listernerForSSHTunnelDown:(NSNotification *)notification
{	
    [[_stdOut fileHandleForReading] closeFile];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSTaskDidTerminateNotification object:_sshTask];
    [self setConnected:NO];
    [self setConnectionInProgress:NO];
    [self callbackWithStatus:SMSSHTaskStatusDisconnected error:nil];
}

- (void)callbackWithStatus:(SMSSHTaskStatus)status error:(NSError *)error
{
    _currentStatus = status;
    _callback(status, error);
    if (error)
    {
        [self disconnect];
    }
}

@end
