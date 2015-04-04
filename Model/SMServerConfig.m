//
//  SMServerConfig.m
//  SSHMole
//
//  Created by openthread on 4/4/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMServerConfig.h"
#import "YYYJsonParser.h"

@implementation SMServerConfig

- (id)init
{
    self = [super init];
    return self;
}

- (BOOL)ableToConnect
{
    if (self.serverName.length == 0)
    {
        return NO;
    }
    if (self.account.length == 0)
    {
        return NO;
    }
    if (self.password.length == 0)
    {
        return NO;
    }
    if (self.serverPort == 0)
    {
        return NO;
    }
    if (self.localPort == 0)
    {
        return NO;
    }
    return YES;
}

- (NSString *)accountStringForKeychain
{
    NSString *account = self.account.length != 0 ? self.account : @"";
    NSString *server = self.serverName.length != 0 ? self.serverName : @"";
    NSString *port = ((self.serverPort != 0 && self.serverName.length != 0) ?
                      [NSString stringWithFormat:@":%tu", self.serverPort] :
                      @"");
    return [NSString stringWithFormat:@"%@%@%@", account, server, port];
}

- (NSDictionary *)commentsDictionaryForKeychain//exclude password
{
    NSMutableDictionary *configDictionary = nil;
    if (self.serverName)
    {
        configDictionary[@"ServerName"] = self.serverName;
    }
    if (self.account)
    {
        configDictionary[@"Account"] = self.account;
    }
    if (self.serverPort != 0)
    {
        configDictionary[@"ServerPort"] = [NSNumber numberWithInteger:self.serverPort];
    }
    if (self.localPort != 0)
    {
        configDictionary[@"LocalPort"] = [NSNumber numberWithInteger:self.localPort];
    }
    NSDictionary *result = [NSDictionary dictionaryWithDictionary:configDictionary];
    return result;
}

- (NSString *)commentsForKeychain
{
    NSDictionary *commentsDictionary = [self commentsDictionaryForKeychain];
    NSString *jsonString = [commentsDictionary JSONString];
    return jsonString;
}

+ (SMServerConfig *)serverConfigWithUnsecuireDictionary:(NSDictionary *)dictionary
                                               password:(NSString *)password
{
    SMServerConfig *config = [[SMServerConfig alloc] init];
    config.password = password;
    config.serverName = dictionary[@"ServerName"];
    config.account = dictionary[@"Account"];
    config.serverPort = [dictionary[@"ServerPort"] integerValue];
    config.localPort = [dictionary[@"LocalPort"] integerValue];
    return config;
}

+ (SMServerConfig *)serverConfigWithKeychainCommentString:(NSString *)keychainCommentString
                                                 password:(NSString *)password
{
    NSDictionary *unsecuireDictionary = [keychainCommentString objectFromJSONString];
    SMServerConfig *config = [self serverConfigWithUnsecuireDictionary:unsecuireDictionary
                                                              password:password];
    return config;
}

@end
