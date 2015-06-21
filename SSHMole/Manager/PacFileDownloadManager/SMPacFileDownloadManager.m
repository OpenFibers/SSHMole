//
//  SMPacFileDownloadManager.m
//  SSHMole
//
//  Created by openthread on 6/22/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMPacFileDownloadManager.h"

@implementation SMPacFileDownloadManager

+ (instancetype)defaultManager
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
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
    
}


/**
 *  获取白名单pac。
 *  文件地址: https://raw.githubusercontent.com/n0wa11/gfw_whitelist/master/whitelist.pac
 *  项目主页: https://github.com/n0wa11/gfw_whitelist
 *  本地缓存地址: ~/Library/Containers/openthread.SSHMole/Data/Documents/whitelist.pac
 *
 *  @param shouldUpdate 是否从远端获取后更新
 *  @param completion   完成handler
 */
- (void)getWhiteListPacDataAndUpdate:(BOOL)shouldUpdate
                          completion:(void(^)(NSData *data))completion
{
#warning cache path unfinished
    NSURL *url = [NSURL URLWithString:@"https://raw.githubusercontent.com/n0wa11/gfw_whitelist/master/whitelist.pac"];
    [self getPacDataWithURL:url
                  cachePath:@""
              replaceOption:nil
                 completion:completion];
}

/**
 *  获取白名单pac。
 *  文件地址?
 *
 *  @param shouldUpdate 是否从远端获取后更新
 *  @param completion   完成handler
 */
- (void)getBlackListPacDataAndUpdate:(BOOL)shouldUpdate
                          completion:(void(^)(NSData *data))completion
{
#warning todo
}

@end
