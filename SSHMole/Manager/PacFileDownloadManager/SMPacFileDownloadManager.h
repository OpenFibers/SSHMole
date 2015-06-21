//
//  SMPacFileDownloadManager.h
//  SSHMole
//
//  Created by openthread on 6/22/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMPacFileDownloadManager : NSObject

+ (instancetype)defaultManager;

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
                          completion:(void(^)(NSData *data))completion;

/**
 *  获取白名单pac。
 *  本地缓存地址: ~/Library/Containers/openthread.SSHMole/Data/Documents/blacklist.pac
 *
 *  @param shouldUpdate 是否从远端获取后更新
 *  @param completion   完成handler
 */
- (void)getBlackListPacDataAndUpdate:(BOOL)shouldUpdate
                          completion:(void(^)(NSData *data))completion;

@end
