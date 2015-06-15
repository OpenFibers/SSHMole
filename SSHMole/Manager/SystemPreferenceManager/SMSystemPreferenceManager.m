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
    SMServerConfig *_currentConfig;
}

+ (instancetype)defaultManager
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
#warning todo: change proxy mode with other settings.
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

- (void)setCurrentProxySettingsByConfig:(SMServerConfig *)config
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
    else
    {
        if (_proxyMode == SMSystemProferenceManagerProxyModeGlobal)
        {
            NSString *localPortString = [NSString stringWithFormat:@"%zd", _currentConfig.localPort];
            [self runSystemConfigurationHelperWithMode:@"global" localPort:localPortString];
        }
        else if (_proxyMode == SMSystemProferenceManagerProxyModeAuto)
        {
#warning change local port string to http server port
            NSString *localPortString = @"8091";
            [self runSystemConfigurationHelperWithMode:@"auto" localPort:localPortString];
        }
    }
}

- (void)runSystemConfigurationHelperWithMode:(NSString *)mode localPort:(NSString *)localPort
{
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
}

@end
