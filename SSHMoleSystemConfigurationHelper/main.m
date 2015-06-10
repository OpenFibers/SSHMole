//
//  main.m
//  SSHMoleSystemConfigurationHelper
//
//  Created by openthread on 6/10/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

NSInteger default_local_port_for_mode(NSString *mode);
OSStatus authorize(AuthorizationRef *authorization);

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        NSArray *supportedArgs = @[@"off", @"auto", @"global"];
        const char* usageString = "usage: SSHMoleSystemConfigurationHelper off|auto|global [localPort]\n";
        //For global mode, localPort means local forwarding port, default is 7070.
        //And for auto mode, localPort means pac local server port, default is 9090.
        
        //If argc not supported, return
        if (argc < 2)
        {
            printf("%s", usageString);
            return 1;
        }

        //If mode not supported, return
        NSString *mode = [NSString stringWithUTF8String:argv[1]];
        if (![supportedArgs containsObject:mode])
        {
            printf("%s", usageString);
            return 1;
        }
        
        //Authentication
        static AuthorizationRef authRef;
        OSStatus authErr = authorize(&authRef);
        if (authErr != noErr || authRef == nil)
        {
            NSLog(@"No authorization has been granted to modify network configuration");
            return 1;
        }
        
        //Set up localPort
        NSInteger localPort = default_local_port_for_mode(mode);
        if (argc >= 3)
        {
            NSString *localPortString = [NSString stringWithUTF8String:argv[2]];
            localPort = [localPortString integerValue];
        }
        
        //Set system preferences
        SCPreferencesRef prefRef = SCPreferencesCreateWithAuthorization(nil, CFSTR("SSHMole"), nil, authRef);
        
        NSDictionary *sets = (__bridge NSDictionary *)SCPreferencesGetValue(prefRef, kSCPrefNetworkServices);
        
        NSMutableDictionary *proxies = [[NSMutableDictionary alloc] init];
        [proxies setObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCFNetworkProxiesHTTPEnable];
        [proxies setObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCFNetworkProxiesHTTPSEnable];
        [proxies setObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCFNetworkProxiesProxyAutoConfigEnable];
        [proxies setObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCFNetworkProxiesSOCKSEnable];
        
        for (NSString *key in [sets allKeys])
        {
            NSMutableDictionary *dict = [sets objectForKey:key];
            NSString *hardware = [dict valueForKeyPath:@"Interface.Hardware"];
            if ([hardware isEqualToString:@"AirPort"] || [hardware isEqualToString:@"Wi-Fi"] || [hardware isEqualToString:@"Ethernet"])
            {
                if ([mode isEqualToString:@"auto"])
                {
                    NSString *urlString = [NSString stringWithFormat:@"http://127.0.0.1:%zd/proxy.pac", localPort];
                    [proxies setObject:urlString forKey:(NSString *)kCFNetworkProxiesProxyAutoConfigURLString];
                    [proxies setObject:[NSNumber numberWithInt:1] forKey:(NSString *)kCFNetworkProxiesProxyAutoConfigEnable];
                }
                else if ([mode isEqualToString:@"global"])
                {
                    [proxies setObject:@"127.0.0.1" forKey:(NSString *)
                     kCFNetworkProxiesSOCKSProxy];
                    [proxies setObject:[NSNumber numberWithInteger:localPort] forKey:(NSString*)
                     kCFNetworkProxiesSOCKSPort];
                    [proxies setObject:[NSNumber numberWithInt:1] forKey:(NSString*)
                     kCFNetworkProxiesSOCKSEnable];
                }
                SCPreferencesPathSetValue(prefRef, (__bridge CFStringRef)[NSString stringWithFormat:@"/%@/%@/%@", kSCPrefNetworkServices, key, kSCEntNetProxies], (__bridge CFDictionaryRef)proxies);
            }
        }
        
        SCPreferencesCommitChanges(prefRef);
        SCPreferencesApplyChanges(prefRef);
        SCPreferencesSynchronize(prefRef);
        printf("pac proxy set to %s", [mode UTF8String]);
    }
    return 0;
}

NSInteger default_local_port_for_mode(NSString *mode)
{
    @autoreleasepool
    {
        if ([mode isEqualToString:@"global"])
        {
            return 7070;
        }
        else if ([mode isEqualToString:@"auto"])
        {
            return 9090;
        }
        return 0;
    }
}

/**
 *  Creates a new authorization reference and provides an option to authorize or preauthorize rights.
 *
 *  @param authorization A pointer to an authorization reference. On return, this parameter refers to the authorization session the Security Server creates. Pass NULL if you require a function result but no authorization reference.
 *
 *  @return A result code. See Authorization Services Result Codes.
 */
OSStatus authorize(AuthorizationRef *authorization)
{
    @autoreleasepool
    {
        static AuthorizationRef authRef;
        static AuthorizationFlags authFlags;
        authFlags = kAuthorizationFlagDefaults
        | kAuthorizationFlagExtendRights
        | kAuthorizationFlagInteractionAllowed
        | kAuthorizationFlagPreAuthorize;
        OSStatus authErr = AuthorizationCreate(nil, kAuthorizationEmptyEnvironment, authFlags, &authRef);
        return authErr;
    }
}
