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

- (id)init;

- (BOOL)ableToConnect;

- (NSString *)accountStringForKeychain;

- (BOOL)saveToKeychain;

+ (SMServerConfig *)serverConfigWithKeychainAccountDictionary:(NSDictionary *)dictionary;


@end
