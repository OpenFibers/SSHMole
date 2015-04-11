//
//  SMServerConfig.m
//  SSHMole
//
//  Created by openthread on 4/4/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMServerConfig.h"
#import "YYYJsonParser.h"
#import "SSKeychain.h"

NSString *const SSHMoleKeychainServiceString = @"SSHMole";

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

- (NSString *)sshCommandString
{
    if ([self ableToConnect])
    {
        NSString *result = [NSString stringWithFormat:@"ssh -D %tu %@@%@ -p %tu",
                            self.localPort,
                            self.account,
                            self.serverName,
                            self.serverPort
                            ];
        return result;
    }
    return nil;
}

#pragma mark - Save to keychain

- (NSString *)accountString
{
    NSString *account = ((self.account.length != 0 && self.serverName.length != 0) ?
                         [self.account stringByAppendingString:@"@"] :
                         @"");
    NSString *server = self.serverName.length != 0 ? self.serverName : @"";
    NSString *port = ((self.serverPort != 0 && self.serverName.length != 0) ?
                      [NSString stringWithFormat:@":%tu", self.serverPort] :
                      @"");
    return [NSString stringWithFormat:@"%@%@%@", account, server, port];
}

- (NSString *)accountStringForDisplay
{
    NSString *accountString = [self accountString];
    if (self.remark.length != 0)
    {
        NSString *resultString = [self.remark stringByAppendingFormat:@"(%@)", accountString];
        return resultString;
    }
    return accountString;
}

- (NSDictionary *)commentsDictionaryForKeychain//exclude password
{
    NSMutableDictionary *configDictionary = [NSMutableDictionary dictionary];
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
    if (self.remark)
    {
        configDictionary[@"Remark"] = self.remark;
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

- (BOOL)saveToKeychain
{
    NSString *accountString = [self accountStringForDisplay];
    NSData *passwordData = [self.password dataUsingEncoding:NSUTF8StringEncoding];
    NSString *commentString = [self commentsForKeychain];
    NSString *kind = @"SSH Account";
    BOOL success = [SSKeychain setPasswordData:passwordData
                                    forService:SSHMoleKeychainServiceString
                                       account:accountString
                                          kind:kind
                                      comments:commentString
                                         error:nil];
    return success;
}

#pragma mark - Load from keychain

+ (SMServerConfig *)serverConfigWithUnsecuireDictionary:(NSDictionary *)dictionary
                                               password:(NSString *)password
{
    SMServerConfig *config = [[SMServerConfig alloc] init];
    config.password = password;
    config.serverName = dictionary[@"ServerName"];
    config.account = dictionary[@"Account"];
    config.serverPort = [dictionary[@"ServerPort"] integerValue];
    config.localPort = [dictionary[@"LocalPort"] integerValue];
    config.remark = dictionary[@"Remark"];
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

+ (SMServerConfig *)serverConfigWithKeychainAccountDictionary:(NSDictionary *)dictionary
{
    NSString *comment = [dictionary objectForKey:(__bridge id)kSecAttrComment];
    NSString *account = [dictionary objectForKey:(__bridge id)kSecAttrAccount];
    NSString *password = [SSKeychain passwordForService:SSHMoleKeychainServiceString account:account];
    SMServerConfig *config = [self serverConfigWithKeychainCommentString:comment password:password];
    return config;
}

@end
