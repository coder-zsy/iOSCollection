//
//  Singleton.h
//  XYTest
//
//  Created by 张时疫 on 2018/2/1.
//  Copyright © 2018年 张时疫. All rights reserved.
//

#ifndef Singleton_h
#define Singleton_h

// .h
#define singleton_interface(class) \
+ (instancetype)sharedInstance;

// .m
#define singleton_implementation(class) \
static class *_instance; \
\
+ (id)allocWithZone:(struct _NSZone *)zone \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [super allocWithZone:zone]; \
}); \
\
return _instance; \
} \
\
+ (instancetype)sharedInstance \
{ \
if (_instance == nil) { \
_instance = [[class alloc] init]; \
} \
\
return _instance; \
}\
\
-(id)copyWithZone:(NSZone *)zone{\
return _instance;\
}\
\
-(id)mutableCopyWithZone:(NSZone *)zone{\
return _instance;\
}

#endif /* Singleton_h */
