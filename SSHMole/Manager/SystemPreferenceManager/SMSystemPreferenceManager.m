//
//  SMSystemPreferenceManager.m
//  SSHMole
//
//  Created by openthread on 6/8/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMSystemPreferenceManager.h"
#import "SMCopyHelperWrapper.h"
#import "SMServerConfig.h"

@implementation SMSystemPreferenceManager
{
    NSUInteger _pacHTTPServerPort;
    SMServerConfig *_currentConfig;
}

+ (instancetype)managerWithPacHTTPServerPort:(NSUInteger)port
{
    id manager = [[self alloc] initWithPacHTTPServerPort:port];
    return manager;
}

- (id)initWithPacHTTPServerPort:(NSUInteger)port
{
    self = [super init];
    if (self)
    {
        _pacHTTPServerPort = port;
        _proxyMode = SMSystemProferenceManagerProxyModeGlobal;
    }
    return self;
}

- (void)setProxyMode:(SMSystemProferenceManagerProxyMode)proxyMode
{
    if (_proxyMode != proxyMode)
    {
        _proxyMode = proxyMode;
        [self updateProxySettings];
    }
}

- (void)updateCurrentProxySettingsForConfig:(SMServerConfig *)config
{
    if (_currentConfig != config)
    {
        _currentConfig = config;
        [self updateProxySettings];
    }
}

- (void)updateProxySettings
{
    if (_currentConfig == nil)
    {
        [self runSystemConfigurationHelperWithMode:@"off" localPort:nil];
    }
    else if (_proxyMode == SMSystemProferenceManagerProxyModeOff)
    {
        [self runSystemConfigurationHelperWithMode:@"off" localPort:nil];
    }
    else if (_proxyMode == SMSystemProferenceManagerProxyModeGlobal)
    {
        NSString *localPortString = [NSString stringWithFormat:@"%zd", _currentConfig.localPort];
        [self runSystemConfigurationHelperWithMode:@"global" localPort:localPortString];
    }
    else if (_proxyMode == SMSystemProferenceManagerProxyModeAuto)
    {
        NSString *localPortString = [NSString stringWithFormat:@"%tu", _pacHTTPServerPort];
        [self runSystemConfigurationHelperWithMode:@"auto" localPort:localPortString];
    }
}

- (void)runSystemConfigurationHelperWithMode:(NSString *)mode localPort:(NSString *)localPort
{
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSTask *task;
        task = [[NSTask alloc] init];
        [task setLaunchPath:[SMCopyHelperWrapper helperPath]];
        
        NSArray *arguments;
        arguments = [NSArray arrayWithObjects:mode, localPort, nil];
        [task setArguments:arguments];
        
        NSPipe *stdoutpipe;
        stdoutpipe = [NSPipe pipe];
        [task setStandardOutput:stdoutpipe];
        
        NSPipe *stderrpipe;
        stderrpipe = [NSPipe pipe];
        [task setStandardError:stderrpipe];
        
        NSFileHandle *file;
        file = [stdoutpipe fileHandleForReading];
        
        [task launch];
        
        NSData *data;
        data = [file readDataToEndOfFile];
        
        NSString *string;
        string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (string.length > 0)
        {
            NSLog(@"SSHMole: change network settings result: %@", string);
        }
        
        file = [stderrpipe fileHandleForReading];
        data = [file readDataToEndOfFile];
        string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (string.length > 0)
        {
            NSLog(@"SSHMole: change network settings error: %@", string);
        }
    });
}

@end
