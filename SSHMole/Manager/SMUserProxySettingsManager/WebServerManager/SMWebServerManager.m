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

- (void)dealloc
{
    [self stopPacServer];
}

- (BOOL)beginPacServerWithPort:(NSUInteger)port data:(NSData *)data path:(NSString *)path error:(NSError **)error
{
    if (_server)
    {
        [_server stop];
        _server = nil;
    }
    _server = [[GCDWebServer alloc] init];
    [_server addHandlerForMethod:@"GET"
                            path:path
                    requestClass:[GCDWebServerRequest class]
                    processBlock:^GCDWebServerResponse *(GCDWebServerRequest *request) {
                        return [GCDWebServerDataResponse responseWithData:data
                                                              contentType:@"application/x-ns-proxy-autoconfig"];
                    }
     ];
    BOOL successed = [_server startWithPort:port bonjourName:@"SSHMole pac server" error:error];
    return successed;
}

- (void)stopPacServer
{
    [_server stop];
    _server = nil;
}


@end
