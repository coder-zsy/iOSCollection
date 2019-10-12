//
//  NSObject+MethodSwizzling.h
//  XYTest
//
//  Created by 张时疫 on 2019/7/9.
//  Copyright © 2019 张时疫. All rights reserved.
//

#import <Foundation/Foundation.h>
 #import <objc/runtime.h>
NS_ASSUME_NONNULL_BEGIN

@interface NSObject (MethodSwizzling)

+ (void)lbp_swizzleMethod:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector;
+ (void)lbp_swizzleClassMethod:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector;

@end

NS_ASSUME_NONNULL_END
