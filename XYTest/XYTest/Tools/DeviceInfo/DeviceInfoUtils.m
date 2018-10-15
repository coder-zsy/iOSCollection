//
//  DeviceInfoUtils.m
//  jiedanyi3
//
//  Created by 张时疫 on 2018/6/13.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "DeviceInfoUtils.h"
#import <sys/utsname.h>
@implementation DeviceInfoUtils

+ (NSString *)getAppVersion {
  NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
  // 获取App的版本号
  NSString *appVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
  // 获取App的build版本
  //    NSString *appBuildVersion = [infoDic objectForKey:@"CFBundleVersion"];
  // 获取App的名称
  //    NSString *appName = [infoDic objectForKey:@"CFBundleDisplayName"];
  return appVersion;
}

+ (BOOL)takePhoneWithPhoneNum:(NSString *)phoneNum {
  NSMutableString * string = [[NSMutableString alloc] initWithFormat:@"telprompt://%@",phoneNum];
  return [DeviceInfoUtils openUrlWithUrlString:string];
}

+ (NSString *)getPushNotificationDeviceToken {
  NSString * deviceToken = [NSUserDefaults stringForKey:REMOTE_NOTIFICATION_DEVICETOKEN];
  deviceToken = deviceToken && deviceToken.length > 0 ? deviceToken : @"";
  return deviceToken;
}

+ (BOOL)openJDYAtAppStore {
  NSString* appstoreUrlString =@"itms-apps://itunes.apple.com/cn/app/id1004977556?mt=8";
  return [DeviceInfoUtils openUrlWithUrlString:appstoreUrlString];
}

+ (BOOL)openJDYCommandAtAppStore {
  NSString*appstoreUrlString = [NSString stringWithFormat:
                                @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=1004977556"];
  return [DeviceInfoUtils openUrlWithUrlString:appstoreUrlString];
}

+ (void)resetApiPrefixWithDictionary:(NSDictionary *)dictionary {
  for (NSString * apiName in dictionary.allKeys) {
    NSString * url = [dictionary objectForKey:apiName];
    if ([apiName isEqualToString:API_PREFIX_BASEURL]) {
      [NSUserDefaults setObject:url forKey:API_PREFIX_BASEURL];
    } else if ([apiName isEqualToString:API_PREFIX_HTMLURL]) {
      [NSUserDefaults setObject:url forKey:API_PREFIX_HTMLURL];
    } else if ([apiName isEqualToString:API_PREFIX_EVENTURL]) {
      [NSUserDefaults setObject:url forKey:API_PREFIX_EVENTURL];
    } else if ([apiName isEqualToString:API_PREFIX_WWWURL]) {
      [NSUserDefaults setObject:url forKey:API_PREFIX_WWWURL];
    }
  }
}

+ (BOOL)openSafariWithUrl:(NSString *)url {
  // 把https://带上
  if (![url containsString:@"https"]) {
    url = [NSString stringWithFormat:@"https://%@",url];
  }
  return [DeviceInfoUtils openUrlWithUrlString:url];
}

+ (BOOL)openUrlWithUrlString:(NSString *)urlString {
  NSURL* url = [NSURL URLWithString:urlString];
  if (@available(iOS 10.0, *)) {
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
      
    }];
    return YES;
  } else {
    if ([[UIApplication sharedApplication] openURL:url]) {
      return  [[UIApplication sharedApplication] openURL:url];
    } else {
      XYLog(@"can not open");
      return NO;
    }
  }
}

/**
 * 有刘海的手机...
 */
+ (BOOL)hasBangDevice {
  NSString * deviceModel = [DeviceInfoUtils deviceModelName];
  if ([deviceModel isEqualToString:@"iPhone X"] || [deviceModel isEqualToString:@"iPhone XR"] || [deviceModel isEqualToString:@"iPhone XS"] || [deviceModel isEqualToString:@"iPhone XS Max"]) {
    return YES;
  }
  return NO;
}

+ (NSString*)deviceModelName {
  struct utsname systemInfo;
  uname(&systemInfo);
  // NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
  NSString * platform = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
  if([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
  if([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
  if([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
  if([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
  if([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
  if([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
  if([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
  if([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
  if([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
  if([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
  if([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
  if([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
  if([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
  if([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
  if([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
  if([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
  if([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
  if([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
  if([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
  if([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
  if([platform isEqualToString:@"iPhone10,1"]) return @"iPhone 8";
  if([platform isEqualToString:@"iPhone10,4"]) return @"iPhone 8";
  if([platform isEqualToString:@"iPhone10,2"]) return @"iPhone 8 Plus";
  if([platform isEqualToString:@"iPhone10,5"]) return @"iPhone 8 Plus";
  if([platform isEqualToString:@"iPhone10,3"]) return @"iPhone X";
  if([platform isEqualToString:@"iPhone10,6"]) return @"iPhone X";
  if([platform isEqualToString:@"iPhone11,8"]) return @"iPhone XR";
  if([platform isEqualToString:@"iPhone11,2"]) return @"iPhone XS";
  if([platform isEqualToString:@"iPhone11,4"]) return @"iPhone XS Max";
  if([platform isEqualToString:@"iPhone11,6"]) return @"iPhone XS Max";
  if([platform isEqualToString:@"iPod1,1"]) return @"iPod Touch 1G";
  if([platform isEqualToString:@"iPod2,1"]) return @"iPod Touch 2G";
  if([platform isEqualToString:@"iPod3,1"]) return @"iPod Touch 3G";
  if([platform isEqualToString:@"iPod4,1"]) return @"iPod Touch 4G";
  if([platform isEqualToString:@"iPod5,1"]) return @"iPod Touch 5G";
  if([platform isEqualToString:@"iPad1,1"]) return @"iPad 1G";
  if([platform isEqualToString:@"iPad2,1"]) return @"iPad 2";
  if([platform isEqualToString:@"iPad2,2"]) return @"iPad 2";
  if([platform isEqualToString:@"iPad2,3"]) return @"iPad 2";
  if([platform isEqualToString:@"iPad2,4"]) return @"iPad 2";
  if([platform isEqualToString:@"iPad2,5"]) return @"iPad Mini 1G";
  if([platform isEqualToString:@"iPad2,6"]) return @"iPad Mini 1G";
  if([platform isEqualToString:@"iPad2,7"]) return @"iPad Mini 1G";
  if([platform isEqualToString:@"iPad3,1"]) return @"iPad 3";
  if([platform isEqualToString:@"iPad3,2"]) return @"iPad 3";
  if([platform isEqualToString:@"iPad3,3"]) return @"iPad 3";
  if([platform isEqualToString:@"iPad3,4"]) return @"iPad 4";
  if([platform isEqualToString:@"iPad3,5"]) return @"iPad 4";
  if([platform isEqualToString:@"iPad3,6"]) return @"iPad 4";
  if([platform isEqualToString:@"iPad4,1"]) return @"iPad Air";
  if([platform isEqualToString:@"iPad4,2"]) return @"iPad Air";
  if([platform isEqualToString:@"iPad4,3"]) return @"iPad Air";
  if([platform isEqualToString:@"iPad4,4"]) return @"iPad Mini 2G";
  if([platform isEqualToString:@"iPad4,5"]) return @"iPad Mini 2G";
  if([platform isEqualToString:@"iPad4,6"]) return @"iPad Mini 2G";
  if([platform isEqualToString:@"iPad4,7"]) return @"iPad Mini 3";
  if([platform isEqualToString:@"iPad4,8"]) return @"iPad Mini 3";
  if([platform isEqualToString:@"iPad4,9"]) return @"iPad Mini 3";
  if([platform isEqualToString:@"iPad5,1"]) return @"iPad Mini 4";
  if([platform isEqualToString:@"iPad5,2"]) return @"iPad Mini 4";
  if([platform isEqualToString:@"iPad5,3"]) return @"iPad Air 2";
  if([platform isEqualToString:@"iPad5,4"]) return @"iPad Air 2";
  if([platform isEqualToString:@"iPad6,3"]) return @"iPad Pro 9.7";
  if([platform isEqualToString:@"iPad6,4"]) return @"iPad Pro 9.7";
  if([platform isEqualToString:@"iPad6,7"]) return @"iPad Pro 12.9";
  if([platform isEqualToString:@"iPad6,8"]) return @"iPad Pro 12.9";
  if([platform isEqualToString:@"i386"]) return @"iPhone Simulator";
  if([platform isEqualToString:@"x86_64"]) return @"iPhone Simulator";
  return platform;
}

@end
