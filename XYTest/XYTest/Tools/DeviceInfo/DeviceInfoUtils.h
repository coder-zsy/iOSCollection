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

/** 是否是模拟器 */
+ (BOOL)isSimulator;
/** 获取 APP 版本 */
+ (NSString *)getAppVersion;
/** 获取系统版本 */
+ (NSString *)getSystemVersion;
/** 打电话 */
+ (BOOL)takePhoneWithPhoneNum:(NSString *)phoneNum;
/** 在 AppStore 打开接单易 */
+ (BOOL)openJDYAtAppStore;
/** 在AppStore 打开接单易评价 */
+ (BOOL)openJDYCommandAtAppStore;
/** 用 Safari 打开链接 */
+ (BOOL)openSafariWithUrl:(NSString *)url;

/** 内部调用
 * 打开链接，遵守Apple 协议，可以打开电话、网页、APP 等
 */
+ (BOOL)openUrlWithUrlString:(NSString *)urlString;

/** 有刘海的手机... */
+ (BOOL)hasBangDevice;
+ (BOOL)isIPhoneXSeries;
/** 检测设备型号 */
+ (NSString*)deviceModelName;
/** 获取手机 IMSI
 * 主要由两部分组成：
 * Mobile Country Code 移动国家码
   国际电联（ITU）统一分配 ，中国区是 460
 * Mobile Network Code 移动网络号码，用于识别运营商网络 ，由二到三个十进制数组成
   中国移动 MNC：00、02、07
   中国联通 MNC：01、06、09
   中国电信 MNC：03、05、11 */
+ (NSString *)getIMSI;
/** 获取运营商信息 */
+ (NSString *)getOperatorInfo;
/** 当前设备是否越狱 */
+ (BOOL)isDevicePrisionBreak;
/** 获取手机电量 */
+ (CGFloat)getDeviceBattery;
/** 获取手机充电状态 */
+ (NSInteger)getDeviceBatteryStatus;
/** 检查当前是否连网 */
+ (BOOL)whetherConnectedNetwork;
/** 获取网络状态，通过遍历状态栏 */
+ (NSDictionary *)getNetworkType;
/** 获取网络信号强度（dBm），通过遍历状态栏
x ~ -110dBm：基本无信号
 -110dBm ~ -90dBm：信号贼差
 -90dBm ~ -75dBm：信号一般
 -75dBm ~ -60dBm：信号还行
 -60dBm ~ x ：信号贼强
 */
//+ (NSInteger)getNetworkStrength;

/** WIFI IP地址 */
+ (NSString *)getIPAddress;


/** 获取 WIFI 信息
 * #import <SystemConfiguration/CaptiveNetwork.h>
 * iOS 13 后该 API 不可用*/
+ (id)getWifiSSIDInfo;
/** 获取 WIFI 名称 */
+ (NSString *)getWifiSSID;
/** 获取WIFI的MAC地址 */
+ (NSString *)getWifiBSSID;

@end
