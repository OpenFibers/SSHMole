//
//  OTIPv4v6AddressConverter.h
//  OTIPv4v6AddressConverterDemo
//
//  Created by openthread on 6/21/16.
//  Copyright © 2016 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTIPv4v6AddressAdapter : NSObject

+ (nullable NSString *)adaptedAddressForOriginalIPAddress:(nonnull NSString *)originalAddress;

@end
