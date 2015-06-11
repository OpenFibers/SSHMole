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

@interface SMServerConfig ()

//Account string in keychain. Use as key in server config storage
//Format username@server_address:server_port
- (NSString *)accountAndServerAddressString;

@end

@implementation SMServerConfig

- (id)init
{
    self = [super init];
    if (self)
    {
        self.serverAddress = @"";
        self.account = @"";
        self.password = @"";
        self.remark = @"";
    }
    return self;
}

- (BOOL)isEqualTo:(id)object
{
    if (self == object)
    {
        return YES;
    }
    if ([object isKindOfClass:[SMServerConfig class]])
    {
        NSString *objectAccountAndServerAddress = ((SMServerConfig *)object).accountAndServerAddressString;
        BOOL result = [self.accountAndServerAddressString isEqualToString:objectAccountAndServerAddress];
        return result;
    }
    return [super isEqualTo:object];
}

- (NSUInteger)hash
{
    NSString *objectAccountAndServerAddress = self.accountAndServerAddressString;
    NSUInteger hash = [objectAccountAndServerAddress hash];
    return hash;
}

#pragma mark - Properties for read

+ (NSString *)safeStringForString:(NSString *)string
{
    return string ? string : @"";
}

- (NSString *)serverAddress
{
    return [[self class] safeStringForString:_serverAddress];
}

- (NSString *)account
{
    return [[self class] safeStringForString:_account];
}

- (NSString *)password
{
    return [[self class] safeStringForString:_password];
}

- (NSString *)remark
{
    return [[self class] safeStringForString:_remark];
}

#pragma mark - Connection methods

- (BOOL)ableToConnect
{
    if (self.serverAddress.length == 0)
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
                            self.serverAddress,
                            self.serverPort
                            ];
        return result;
    }
    return nil;
}

#pragma mark - Save to keychain

//Account string in keychain. Use as key in server config storage
//Format username@server_address:server_port
- (NSString *)accountAndServerAddressString
{
    NSString *account = ((self.account.length != 0 && self.serverAddress.length != 0) ?
                         [self.account stringByAppendingString:@"@"] :
                         @"");
    NSString *server = self.serverAddress.length != 0 ? self.serverAddress : @"";
    NSString *port = ((self.serverPort != 0 && self.serverAddress.length != 0) ?
                      [NSString stringWithFormat:@":%tu", self.serverPort] :
                      @"");
    return [NSString stringWithFormat:@"%@%@%@", account, server, port];
}

- (NSString *)accountStringForDisplay
{
    if (self.remark.length != 0)
    {
        return self.remark;
    }
    return [self accountAndServerAddressString];
}

- (NSString *)identifierString
{
    return [self accountAndServerAddressString];
}

- (NSDictionary *)commentsDictionaryForKeychain//exclude password
{
    NSMutableDictionary *configDictionary = [NSMutableDictionary dictionary];
    if (self.serverAddress)
    {
        configDictionary[@"ServerName"] = self.serverAddress;
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
    if ([self accountAndServerAddressString].length == 0)
    {
        return NO;
    }
    
    [self removeFromKeychain];
    
    NSString *accountString = [self accountAndServerAddressString];
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

- (BOOL)removeFromKeychain
{
    NSString *accountString = [self accountAndServerAddressString];
    BOOL succesed = [SSKeychain deletePasswordForService:SSHMoleKeychainServiceString
                                                 account:accountString];
    return succesed;
}

#pragma mark - Load from keychain

+ (SMServerConfig *)serverConfigWithUnsecuireDictionary:(NSDictionary *)dictionary
                                               password:(NSString *)password
{
    SMServerConfig *config = [[SMServerConfig alloc] init];
    config.password = password;
    config.serverAddress = dictionary[@"ServerName"];
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
