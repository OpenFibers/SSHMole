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

@interface SMPacFileDownloadManager () <OTHTTPRequestDelegate>

@end

@implementation SMPacFileDownloadManager
{
    NSMutableDictionary *_requestDictionary;
    NSMutableDictionary *_callbackDictionary;
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
    }
    return self;
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
    NSString *localServerString = [NSString stringWithFormat:@"var IP_ADDRESS = '127.0.0.1:%tu';", localPort];
    NSDictionary *replaceOption = @{@"var IP_ADDRESS = 'www.abc.com:443';": localServerString,
                                    @"var PROXY_TYPE = 'HTTPS';": @"var PROXY_TYPE = 'SOCKS5';",
                                    };
    [self getPacDataWithURL:(shouldUpdate ? url : nil)
                  cachePath:cachePath
              replaceOption:replaceOption
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
#warning todo
}

/**
 *  获取pac data，从url更新到缓存，或者直接从缓存读取
 *
 *  @param url           pac的远程url。如果不填，则直接从本地缓存读取。
 *  @param cachePath     本地缓存地址。如果传了url，则下载后更新到cachePath
 *  @param replaceOption 字符串替换dictionary，pac中匹配到key会被替换成value
 *  @param completion    完成的handler
 */
- (void)getPacDataWithURL:(NSURL *)url
                cachePath:(NSString *)cachePath
            replaceOption:(NSDictionary *)replaceOption
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
    
    __weak id weakSelf = self;
    if (url.absoluteString)
    {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        userInfo[@"cachePath"] = cachePath;
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
            data = [weakSelf getReplacedPacStringForOriginalData:data replaceOptions:replaceOption];
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
        
        __weak id weakSelf = self;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *responseData = request.responseData;
            if (callback)
            {
                NSData *data = [weakSelf getReplacedPacStringForOriginalData:responseData
                                                          replaceOptions:replaceOption];
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(data);
                });
            }
            [responseData writeToFile:cachePath atomically:YES];
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
