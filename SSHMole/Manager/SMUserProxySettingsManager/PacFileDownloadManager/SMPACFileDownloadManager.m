//
//  SMPacFileDownloadManager.m
//  SSHMole
//
//  Created by openthread on 6/22/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMPACFileDownloadManager.h"
#import "OTHTTPRequest.h"
#import "SMSandboxPath.h"
#import "SMPACFileObserverManager.h"
#import "SMAlertHelper.h"

static NSString *const ServerAndPortOptionString = @"/*<SSHMole Local Server DO NOT CHANGE>*/";

@interface SMPACFileDownloadManager () <OTHTTPRequestDelegate, SMPACFileObserverManagerFileDeletedDelegate>

@end

@implementation SMPACFileDownloadManager
{
    NSMutableDictionary *_requestDictionary;
    
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
        
        NSString *whitelistIPAddressString = [NSString stringWithFormat:@"var IP_ADDRESS = '%@';", ServerAndPortOptionString];
        _whitelistReplaceOption = @{@"var IP_ADDRESS = 'www.abc.com:443';": whitelistIPAddressString,
                                    @"var PROXY_TYPE = 'HTTPS';": @"var PROXY_TYPE = 'SOCKS';",
                                    };
        _blacklistReplaceOption = @{@"127.0.0.1:1080": ServerAndPortOptionString};
        
        [SMPACFileObserverManager defaultManager].pacDeleteDelegate = self;
        
        [self installDefaultPacIfNotExist];
    }
    return self;
}

#pragma mark - Install default PAC files

- (void)installDefaultPacIfNotExist
{
    [self installDefaultPacIfNotExistForFileName:SMSandboxWhitelistPACFileName replaceOption:_whitelistReplaceOption];
    [self installDefaultPacIfNotExistForFileName:SMSandboxBlacklistPACFileName replaceOption:_blacklistReplaceOption];
}

- (void)installDefaultPacIfNotExistForFileName:(NSString *)fileName replaceOption:(NSDictionary *)replaceOption
{
    NSString *cachePath = [SMSandboxPath pacPathForName:fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath])
    {
        NSString *pacSuperPath = [cachePath stringByDeletingLastPathComponent];
        if (![[NSFileManager defaultManager] fileExistsAtPath:pacSuperPath])
        {
            NSError *error = nil;
            BOOL successed = [[NSFileManager defaultManager] createDirectoryAtPath:pacSuperPath withIntermediateDirectories:YES attributes:nil error:&error];
            if (!successed)
            {
                NSString *errorString = [NSString stringWithFormat:@"%@\n%@", error.domain, error.localizedDescription];
                [SMAlertHelper showAlertWithOKButtonAndString:errorString];
            }
            else
            {
                [self writeBundleResourceWithFileName:fileName toCachePath:cachePath replaceOption:replaceOption];
            }
        }
        else
        {
            [self writeBundleResourceWithFileName:fileName toCachePath:cachePath replaceOption:replaceOption];
        }
    }
}

- (void)writeBundleResourceWithFileName:(NSString *)fileName toCachePath:(NSString *)cachePath replaceOption:(NSDictionary *)replaceOption
{
    NSString *pacPathInBundle = [[NSBundle mainBundle] pathForResource:fileName ofType:@""];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *originalData = [[NSData alloc] initWithContentsOfFile:pacPathInBundle];
        NSData *replacedData = [SMPACFileDownloadManager getReplacedPacStringForOriginalData:originalData replaceOptions:replaceOption];
        [replacedData writeToFile:cachePath atomically:YES];
    });
}

#pragma mark - PAC File Deleted Delegate

- (void)PACFileObserverManagerWhitelistPACDeleted:(SMPACFileObserverManager *)manager
{
    [self installDefaultPacIfNotExistForFileName:SMSandboxWhitelistPACFileName replaceOption:_whitelistReplaceOption];
}

- (void)PACFileObserverManagerBlacklistPACDeleted:(SMPACFileObserverManager *)manager
{
    [self installDefaultPacIfNotExistForFileName:SMSandboxBlacklistPACFileName replaceOption:_blacklistReplaceOption];    
}

#pragma mark - Get local PAC data

/**
 *  读取本地的白名单PAC文件内容
 *
 *  @param localPort  本地转发端口，用于PAC文件内文本替换
 *  @param completion 完成回调
 */
- (void)getWhiteListLocalPacDataForLocalPort:(NSUInteger)localPort
                                  completion:(void(^)(NSData *data))completion
{
    NSString *cachePath = [SMSandboxPath pacPathForName:SMSandboxWhitelistPACFileName];
    [self getLocalPacDataForCachePath:cachePath localPort:localPort completion:completion];
}

/**
 *  读取本地的黑名单PAC文件内容
 *
 *  @param localPort  本地转发端口，用于PAC文件内文本替换
 *  @param completion 完成回调
 */
- (void)getBlackListLocalPacDataForLocalPort:(NSUInteger)localPort
                                  completion:(void(^)(NSData *data))completion
{
    NSString *cachePath = [SMSandboxPath pacPathForName:SMSandboxBlacklistPACFileName];
    [self getLocalPacDataForCachePath:cachePath localPort:localPort completion:completion];
}

- (void)getLocalPacDataForCachePath:(NSString *)cachePath
                          localPort:(NSUInteger)localPort
                         completion:(void(^)(NSData *data))completion
{
    if (cachePath.length == 0 || localPort == 0)
    {
        if (completion)
        {
            completion(nil);
        }
        return;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath])
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = [[NSData alloc] initWithContentsOfFile:cachePath];
            NSString *localServerAndPortString = [NSString stringWithFormat:@"127.0.0.1:%zd", localPort];
            NSDictionary *localServerReplaceOption = @{ServerAndPortOptionString : localServerAndPortString};
            data = [SMPACFileDownloadManager getReplacedPacStringForOriginalData:data
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

#pragma mark - Update PAC File from Remote

/**
 *  更新白名单文件，从remote
 *
 *  @param completion 完成时的回调
 */
- (void)updatWhitelistPACDataWithCompletion:(void(^)(BOOL successed))completion
{
    NSString *cachePath = [SMSandboxPath pacPathForName:SMSandboxWhitelistPACFileName];
    NSURL *url = [NSURL URLWithString:@"https://raw.githubusercontent.com/n0wa11/gfw_whitelist/master/whitelist.pac"];
    [self updatePacDataWithURL:url cachePath:cachePath replaceOption:_whitelistReplaceOption completion:completion];
}

/**
 *  更新黑名单文件，从remote
 *
 *  @param completion 完成时的回调
 */
- (void)updateBlacklistPACDataWithCompletion:(void(^)(BOOL successed))completion
{
    NSString *cachePath = [SMSandboxPath pacPathForName:SMSandboxBlacklistPACFileName];
    NSURL *url = [NSURL URLWithString:@"https://raw.githubusercontent.com/OpenFibers/SSHMole/master/SSHMole/PacFiles/blacklist.pac"];
    [self updatePacDataWithURL:url cachePath:cachePath replaceOption:_blacklistReplaceOption completion:completion];
}

/**
 *  获取pac data，从url更新到缓存，或者直接从缓存读取
 *
 *  @param url           pac的远程url，如果传空，直接回调
 *  @param cachePath     本地缓存地址，如果传空，直接回调
 *  @param replaceOption 字符串替换dictionary，下载完成时，pac中匹配到key会被替换成value，写入文件
 *  @param completion    完成的handler
 */

- (void)updatePacDataWithURL:(NSURL *)url
                cachePath:(NSString *)cachePath
            replaceOption:(NSDictionary *)replaceOption
               completion:(void(^)(BOOL successed))completion
{
    if (cachePath.length == 0 ||
        url.absoluteString.length == 0)
    {
        if (completion)
        {
            completion(NO);
        }
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[@"cachePath"] = cachePath;
    if (replaceOption)
    {
        userInfo[@"replaceOption"] = replaceOption;
    }
    if (completion)
    {
        userInfo[@"callback"] = completion;
    }
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    OTHTTPRequest *request = [[OTHTTPRequest alloc] initWithNSURLRequest:urlRequest];
    request.userInfo = [NSDictionary dictionaryWithDictionary:userInfo];
    request.delegate = self;
    [request start];
    
    _requestDictionary[url.absoluteString] = request;
}

- (void)otHTTPRequestFinished:(OTHTTPRequest *)request
{
    NSString *key = request.request.URL.absoluteString;
    if (key)
    {
        NSDictionary *userInfo = request.userInfo;
        void (^callback)(BOOL successed) = userInfo[@"callback"];
        NSString *cachePath = userInfo[@"cachePath"];
        NSDictionary *replaceOption = userInfo[@"replaceOption"];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *responseData = request.responseData;
            NSData *data = [SMPACFileDownloadManager getReplacedPacStringForOriginalData:responseData
                                                                          replaceOptions:replaceOption];
            BOOL successed = [data writeToFile:cachePath atomically:YES];
            if (callback)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(successed);
                });
            }
        });
        
        [_requestDictionary removeObjectForKey:key];
    }
}

- (void)otHTTPRequestFailed:(OTHTTPRequest *)request error:(NSError *)error
{
    NSString *key = request.request.URL.absoluteString;
    if (key)
    {
        void (^callback)(BOOL successed) = request.userInfo[@"callback"];
        if (callback)
        {
            callback(NO);
        }
        [_requestDictionary removeObjectForKey:key];
    }
}

#pragma mark - Replace Option

+ (NSData *)getReplacedPacStringForOriginalData:(NSData *)originalData
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
