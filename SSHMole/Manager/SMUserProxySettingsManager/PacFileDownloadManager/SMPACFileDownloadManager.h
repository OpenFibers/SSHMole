//
//  SMPacFileDownloadManager.h
//  SSHMole
//
//  Created by openthread on 6/22/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMPACFileDownloadManager : NSObject

+ (instancetype)defaultManager;

/**
 *  读取本地的全局PAC文件内容
 *
 *  @param localPort  本地转发端口，用于PAC文件内文本替换
 *  @param allowConnectionsFromLAN 代理是否允许局域网内其他设备访问
 *  @param completion 完成回调
 */
- (void)getGlobalLocalPacDataForLocalPort:(NSUInteger)localPort
                  allowConnectionsFromLAN:(BOOL)allowConnectionsFromLAN
                               completion:(void(^)(NSData *data))completion;

/**
 *  读取本地的白名单PAC文件内容
 *
 *  @param localPort  本地转发端口，用于PAC文件内文本替换
 *  @param allowConnectionsFromLAN 代理是否允许局域网内其他设备访问
 *  @param completion 完成回调
 */
- (void)getWhiteListLocalPacDataForLocalPort:(NSUInteger)localPort
                     allowConnectionsFromLAN:(BOOL)allowConnectionsFromLAN
                                  completion:(void(^)(NSData *data))completion;

/**
 *  读取本地的黑名单PAC文件内容
 *
 *  @param localPort  本地转发端口，用于PAC文件内文本替换
 *  @param allowConnectionsFromLAN 代理是否允许局域网内其他设备访问
 *  @param completion 完成回调
 */
- (void)getBlackListLocalPacDataForLocalPort:(NSUInteger)localPort
                     allowConnectionsFromLAN:(BOOL)allowConnectionsFromLAN
                                  completion:(void(^)(NSData *data))completion;

/**
 *  更新白名单文件，从remote
 *
 *  @param completion 完成时的回调
 */
- (void)updatWhitelistPACDataWithCompletion:(void(^)(BOOL successed))completion;

/**
 *  更新黑名单文件，从remote
 *
 *  @param completion 完成时的回调
 */
- (void)updateBlacklistPACDataWithCompletion:(void(^)(BOOL successed))completion;

@end
