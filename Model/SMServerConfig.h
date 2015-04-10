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

@property (nonatomic, strong) NSString *serverName;
@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, assign) NSUInteger serverPort;
@property (nonatomic, assign) NSUInteger localPort;
@property (nonatomic, strong) NSString *remark;

- (id)init;

- (BOOL)ableToConnect;

//Format: ssh -D local_port username@server_address:server_port
- (NSString *)sshCommandString;

//Account string in keychain.
//Format username@server_address:server_port
- (NSString *)accountStringForKeychain;

//Save to keychain
//This method will get called when config added to storage.
- (BOOL)saveToKeychain;

+ (SMServerConfig *)serverConfigWithKeychainAccountDictionary:(NSDictionary *)dictionary;


@end
