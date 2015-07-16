//
//  SMWebServerManager.m
//  SSHMole
//
//  Created by openthread on 6/22/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMWebServerManager.h"
#import "GCDWebServer.h"
#import "GCDWebServerDataResponse.h"

@implementation SMWebServerManager
{
    GCDWebServer *_server;
}

+ (instancetype)defaultManager
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SMWebServerManager alloc] init];
    });
    return manager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _server = [[GCDWebServer alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [self stopPacServer];
    _server = nil;
}

- (BOOL)beginPacServerWithPort:(NSUInteger)port error:(NSError **)error
{
    [self stopPacServer];
    BOOL successed = [_server startWithPort:port bonjourName:@"SSHMole pac server" error:error];
    return successed;
}

- (void)stopPacServer
{
    if ([_server isRunning])
    {
        [_server stop];
        [_server removeAllHandlers];
    }
}

- (void)addHandlerForPath:(NSString *)path data:(NSData *)data
{
    [_server addHandlerForMethod:@"GET"
                            path:path
                    requestClass:[GCDWebServerRequest class]
                    processBlock:^GCDWebServerResponse *(GCDWebServerRequest *request) {
                        return [GCDWebServerDataResponse responseWithData:data
                                                              contentType:@"application/x-ns-proxy-autoconfig"];
                    }
     ];
}

- (void)removeAllHandlers
{
    [_server removeAllHandlers];
}


@end
