//
//  DeviceInfoUtils.h
//  XYTest
//
//  Created by 张时疫 on 2018/6/13.
//  Copyright © 2018年 张时疫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface DeviceInfoUtils : NSObject

+ (NSString *)getAppVersion;

+ (BOOL)takePhoneWithPhoneNum:(NSString *)phoneNum;

+ (BOOL)openSafariWithUrl:(NSString *)url;

+ (BOOL)openJDYAtAppStore;

+ (BOOL)openJDYCommandAtAppStore;

/**
 * 有刘海的手机...
 */
+ (BOOL)hasBangDevice;

+ (NSString*)deviceModelName;
@end
