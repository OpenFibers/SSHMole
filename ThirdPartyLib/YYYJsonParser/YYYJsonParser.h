//
//  YYYJsonParser.h
//  NeteaseMusic
//
//  Created by 史江浩 on 9/25/14.
//  Copyright (c) 2014 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYYJsonParser : NSObject


@end

@interface NSString (YYYJsonParser)
- (id)objectFromJSONString;
@end

@interface NSObject (YYYJsonParser)
- (NSString *)JSONString;
@end


