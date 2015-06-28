//
//  SMPacFileDownloadManager.m
//  SSHMole
//
//  Created by openthread on 6/22/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMPacFileDownloadManager.h"
#import "OTHTTPRequest.h"
#import "SMSandboxPath.h"

static NSString *const ServerAndPortOptionString = @"/*<SSHMole Local Server DO NOT CHANGE>*/";

@interface SMPacFileDownloadManager () <OTHTTPRequestDelegate>

@end

@implementation SMPacFileDownloadManager
{
    NSMutableDictionary *_requestDictionary;
    NSMutableDictionary *_callbackDictionary;
    
    NSDictionary *_whitelistReplaceOption;
    NSDictionary *_blacklistReplaceOption;
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
        _requestDictionary = [NSMutableDictionary dictionary];
        _callbackDictionary = [NSMutableDictionary dictionary];
        
        NSString *whitelistIPAddressString = [NSString stringWithFormat:@"var IP_ADDRESS = '%@';", ServerAndPortOptionString];
        _whitelistReplaceOption = @{@"var IP_ADDRESS = 'www.abc.com:443';": whitelistIPAddressString,
                                    @"var PROXY_TYPE = 'HTTPS';": @"var PROXY_TYPE = 'SOCKS';",
                                    };
        _blacklistReplaceOption = @{@"127.0.0.1:1080": ServerAndPortOptionString};
        
        [self installDefaultPacIfNotExist];
    }
    return self;
}

- (void)installDefaultPacIfNotExist
{
    [self installDefaultPacIfNotExistForFileName:@"whitelist.pac" replaceOption:_whitelistReplaceOption];
    [self installDefaultPacIfNotExistForFileName:@"blacklist.pac" replaceOption:_blacklistReplaceOption];
}

- (void)installDefaultPacIfNotExistForFileName:(NSString *)fileName replaceOption:(NSDictionary *)replaceOption
{
    NSString *cachePath = [SMSandboxPath pacPathForName:fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath])
    {
        NSString *pacSuperPath = [cachePath stringByDeletingLastPathComponent];
        if (![[NSFileManager defaultManager] fileExistsAtPath:pacSuperPath])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:pacSuperPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSString *pacPathInBundle = [[NSBundle mainBundle] pathForResource:fileName ofType:@""];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *originalData = [[NSData alloc] initWithContentsOfFile:pacPathInBundle];
            NSData *replacedData = [self getReplacedPacStringForOriginalData:originalData replaceOptions:replaceOption];
            [replacedData writeToFile:cachePath atomically:YES];
        });
    }
}

/**
 *  获取白名单pac。
 *  文件地址: https://raw.githubusercontent.com/n0wa11/gfw_whitelist/master/whitelist.pac
 *  项目主页: https://github.com/n0wa11/gfw_whitelist
 *  本地缓存地址: ~/Library/Containers/openthread.SSHMole/Data/Documents/whitelist.pac
 *
 *  @param shouldUpdate 是否从远端获取后更新
 *  @param localPort    本地的pac http server端口
 *  @param completion   完成handler
 */
- (void)getWhiteListPacDataAndUpdate:(BOOL)shouldUpdate
                           localPort:(NSUInteger)localPort
                          completion:(void(^)(NSData *data))completion
{
    NSString *cachePath = [SMSandboxPath pacPathForName:@"whitelist.pac"];
    NSURL *url = [NSURL URLWithString:@"https://raw.githubusercontent.com/n0wa11/gfw_whitelist/master/whitelist.pac"];
    NSString *localServerAndPortString = [NSString stringWithFormat:@"127.0.0.1:%zd", localPort];
    [self getPacDataWithURL:(shouldUpdate ? url : nil)
                  cachePath:cachePath
              replaceOption:_whitelistReplaceOption
   localServerAndPortString:localServerAndPortString
                 completion:completion];
}

/**
 *  获取黑名单pac。
 *  文件地址?
 *
 *  @param shouldUpdate 是否从远端获取后更新
 *  @param localPort    本地的pac http server端口
 *  @param completion   完成handler
 */
- (void)getBlackListPacDataAndUpdate:(BOOL)shouldUpdate
                           localPort:(NSUInteger)localPort
                          completion:(void(^)(NSData *data))completion
{
    NSString *cachePath = [SMSandboxPath pacPathForName:@"blacklist.pac"];
    NSURL *url = [NSURL URLWithString:@"https://raw.githubusercontent.com/OpenFibers/SSHMole/master/SSHMole/PacFiles/blacklist.pac"];
    NSString *localServerAndPortString = [NSString stringWithFormat:@"127.0.0.1:%zd", localPort];
    [self getPacDataWithURL:(shouldUpdate ? url : nil)
                  cachePath:cachePath
              replaceOption:_blacklistReplaceOption
   localServerAndPortString:localServerAndPortString
                 completion:completion];
}


/**
 *  获取pac data，从url更新到缓存，或者直接从缓存读取
 *
 *  @param url                      pac的远程url。如果不填，则直接从本地缓存读取。
 *  @param cachePath                本地缓存地址。如果传了url，则下载后更新到cachePath
 *  @param replaceOption            字符串替换dictionary，下载完成时，pac中匹配到key会被替换成value，写入文件
 *  @param localServerAndPortString 本地转发端口地址。从文件中读出调用回调前，会用此地址替换<*Server and Port String*>
 *  @param completion               完成的handler
 */

- (void)getPacDataWithURL:(NSURL *)url
                cachePath:(NSString *)cachePath
            replaceOption:(NSDictionary *)replaceOption
 localServerAndPortString:(NSString *)localServerAndPortString
               completion:(void(^)(NSData *data))completion
{
    if (cachePath.length == 0)
    {
        if (completion)
        {
            completion(nil);
        }
        return;
    }
    
    if (localServerAndPortString.length == 0)
    {
        if (completion)
        {
            completion(nil);
        }
    }
    
    __weak id weakSelf = self;
    if (url.absoluteString)
    {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        userInfo[@"cachePath"] = cachePath;
        userInfo[@"localServerAndPort"] = localServerAndPortString;
        if (replaceOption)
        {
            userInfo[@"replaceOption"] = replaceOption;
        }
        
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        OTHTTPRequest *request = [[OTHTTPRequest alloc] initWithNSURLRequest:urlRequest];
        request.userInfo = [NSDictionary dictionaryWithDictionary:userInfo];
        request.delegate = self;
        [request start];
        
        _requestDictionary[url.absoluteString] = request;
        _callbackDictionary[url.absoluteString] = [completion copy];
    }
    else if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath])
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = [[NSData alloc] initWithContentsOfFile:cachePath];
            NSDictionary *localServerReplaceOption = @{ServerAndPortOptionString : localServerAndPortString};
            data = [weakSelf getReplacedPacStringForOriginalData:data
                                                  replaceOptions:localServerReplaceOption];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion)
                {
                    completion(data);
                }
            });
        });
    }
    else
    {
        if (completion)
        {
            completion(nil);
        }
    }
}

- (void)otHTTPRequestFinished:(OTHTTPRequest *)request
{
    NSString *key = request.request.URL.absoluteString;
    if (key)
    {
        void (^callback)(NSData *data) = _requestDictionary[key];
        
        NSDictionary *userInfo = request.userInfo;
        NSString *cachePath = userInfo[@"cachePath"];
        NSDictionary *replaceOption = userInfo[@"replaceOption"];
        NSString *localServerAndPortString = userInfo[@"localServerAndPort"];
        
        __weak id weakSelf = self;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *responseData = request.responseData;
            NSData *data = [weakSelf getReplacedPacStringForOriginalData:responseData
                                                          replaceOptions:replaceOption];
            if (callback)
            {
                NSDictionary *localServerReplaceOption = @{ServerAndPortOptionString : localServerAndPortString};
                NSData *finalData = [weakSelf getReplacedPacStringForOriginalData:data replaceOptions:localServerReplaceOption];
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(finalData);
                });
            }
            [data writeToFile:cachePath atomically:YES];
        });
        
        [_requestDictionary removeObjectForKey:key];
        [_callbackDictionary removeObjectForKey:key];
        
    }
}

- (void)otHTTPRequestFailed:(OTHTTPRequest *)request error:(NSError *)error
{
    NSString *key = request.request.URL.absoluteString;
    if (key)
    {
        void (^callback)(NSData *data) = _requestDictionary[key];

        [_requestDictionary removeObjectForKey:key];
        [_callbackDictionary removeObjectForKey:key];
        
        if (callback)
        {
            callback(nil);
        }
    }
}

- (NSData *)getReplacedPacStringForOriginalData:(NSData *)originalData
                             replaceOptions:(NSDictionary *)replaceOptions
{
    NSMutableString *utf8String = [[[NSString alloc] initWithData:originalData encoding:NSUTF8StringEncoding] mutableCopy];
    for (NSString *key in replaceOptions.allKeys)
    {
        NSString *value = replaceOptions[key];
        if ([key isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]])
        {
            [utf8String replaceOccurrencesOfString:key withString:value options:0 range:NSMakeRange(0, utf8String.length)];
        }
    }
    NSData *data = [utf8String dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

@end
