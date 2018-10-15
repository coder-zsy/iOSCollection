//
//  DeviceInfoUtils.h
//  jiedanyi3
//
//  Created by 张时疫 on 2018/6/13.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceInfoUtils : NSObject

+ (NSString *)getAppVersion;

+ (BOOL)takePhoneWithPhoneNum:(NSString *)phoneNum;

+ (NSString *)getPushNotificationDeviceToken;

+ (BOOL)openSafariWithUrl:(NSString *)url;

+ (BOOL)openJDYAtAppStore;

+ (BOOL)openJDYCommandAtAppStore;

+ (void)resetApiPrefixWithDictionary:(NSDictionary *)dictionary;

/**
 * 有刘海的手机...
 */
+ (BOOL)hasBangDevice;

+ (NSString*)deviceModelName;
@end
