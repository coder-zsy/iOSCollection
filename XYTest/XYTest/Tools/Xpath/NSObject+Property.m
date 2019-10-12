//
//  NSObject+Property.m
//  XYTest
//
//  Created by 张时疫 on 2019/7/10.
//  Copyright © 2019 张时疫. All rights reserved.
//

#import "NSObject+Property.h"
 #import <objc/runtime.h>
@implementation NSObject (Property)

- (NSArray *)filterPropertys {
    NSMutableArray *props = [NSMutableArray array];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i<outCount; i++) {
        objc_property_t property = *properties;
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        [props addObject:propertyName];
    }
    free(properties);
    return props;
}

@end
