//
//  main.m
//  SSHMoleSystemConfigurationHelper
//
//  Created by openthread on 6/10/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

NSInteger default_local_port_for_global_mode();
NSString * default_pac_url_for_auto_mode();
OSStatus authorize(AuthorizationRef *authorization);

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        NSArray *supportedArgs = @[@"off", @"auto", @"global", @"-v"];
        const char* usageString = "usage: \nSHMoleSystemConfigurationHelper off\nSHMoleSystemConfigurationHelper auto localPort\nSHMoleSystemConfigurationHelper global pacURL\n";
        //For global mode, localPort means local forwarding port, default is 7070.
        //And for auto mode, pacURL means pac local server url, default is http://127.0.0.1:9099/proxy.pac .
        
        //If argc not supported, return
        if (argc < 2)
        {
            printf("%s\n", usageString);
            return 1;
        }

        //If mode not supported, return
        NSString *mode = [NSString stringWithUTF8String:argv[1]];
        if (![supportedArgs containsObject:mode])
        {
            printf("%s\n", usageString);
            return 1;
        }
        
        //Check vesion
        if ([mode isEqualToString:@"-v"])
        {
            printf("1.0\n");
            return 0;
        }
        
        //Authentication
        static AuthorizationRef authRef;
        OSStatus authErr = authorize(&authRef);
        if (authErr != noErr || authRef == nil)
        {
            NSLog(@"No authorization has been granted to modify network configuration");
            return 1;
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
                    NSString *urlString = default_pac_url_for_auto_mode();
                    if (argc >= 3)
                    {
                        urlString = [NSString stringWithUTF8String:argv[2]];
                    }
                    
                    [proxies setObject:urlString forKey:(NSString *)kCFNetworkProxiesProxyAutoConfigURLString];
                    [proxies setObject:[NSNumber numberWithInt:1] forKey:(NSString *)kCFNetworkProxiesProxyAutoConfigEnable];
                }
                else if ([mode isEqualToString:@"global"])
                {
                    NSInteger localPort = default_local_port_for_global_mode();
                    if (argc >= 3)
                    {
                        NSString *localPortString = [NSString stringWithUTF8String:argv[2]];
                        localPort = ABS([localPortString integerValue]);
                    }
                    
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
        printf("pac proxy set to %s\n", [mode UTF8String]);
    }
    return 0;
}

NSInteger default_local_port_for_global_mode()
{
    @autoreleasepool
    {
        
        return 7070;
    }
}

NSString * default_pac_url_for_auto_mode()
{
    @autoreleasepool
    {
        return @"http://127.0.0.1:9099/proxy.pac";
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
        static AuthorizationFlags authFlags;
        authFlags = kAuthorizationFlagDefaults
        | kAuthorizationFlagExtendRights
        | kAuthorizationFlagInteractionAllowed
        | kAuthorizationFlagPreAuthorize;
        OSStatus authErr = AuthorizationCreate(nil, kAuthorizationEmptyEnvironment, authFlags, authorization);
        return authErr;
    }
}
