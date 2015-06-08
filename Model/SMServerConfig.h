//
//  SMServerConfig.h
//  SSHMole
//
//  Created by openthread on 4/4/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const SSHMoleKeychainServiceString;

@interface SMServerConfig : NSObject

@property (nonatomic, strong) NSString *serverAddress;
@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, assign) NSUInteger serverPort;
@property (nonatomic, assign) NSUInteger localPort;
@property (nonatomic, strong) NSString *remark;

- (id)init;

- (BOOL)ableToConnect;

//Format: ssh -D local_port username@server_address:server_port
- (NSString *)sshCommandString;

//Account string for display
//Format: remark(username@server_address:server_port)
- (NSString *)accountStringForDisplay;

/**
 *  The identifier of server config.
 *
 *  @return The identifier of server config.
 */
- (NSString *)identifierString;

/**
 *  Save this config to keychain.
 *  This method will get called when config added to storage.
 *
 *  @return Successed if YES, otherwise NO.
 */
- (BOOL)saveToKeychain;

//Remove from keychain
- (BOOL)removeFromKeychain;

+ (SMServerConfig *)serverConfigWithKeychainAccountDictionary:(NSDictionary *)dictionary;


@end
