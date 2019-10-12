//
//  DeviceInfoUtils.m
//  XYTest
//
//  Created by 张时疫 on 2018/6/13.
//  Copyright © 2018年 张时疫. All rights reserved.
//
#import "DeviceInfoUtils.h"
/** 设备型号 */
#import <sys/utsname.h>
/** 运营商信息 */
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
/** 网络检测 */
#import <SystemConfiguration/SystemConfiguration.h>
#import <SystemConfiguration/CaptiveNetwork.h>

#import <ifaddrs.h>
#import <arpa/inet.h>

/** 越狱检测 */
#import <sys/stat.h>
@implementation DeviceInfoUtils

/** 是否是模拟器 */
+ (BOOL)isSimulator {
#if TARGET_OS_SIMULATOR
    return YES;
#else
    return NO;
#endif
}

/** 获取 APP 版本 */
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

+ (NSString *)getSystemVersion {
    return [UIDevice currentDevice].systemVersion;
}

/** 打电话 */
+ (BOOL)takePhoneWithPhoneNum:(NSString *)phoneNum {
    NSMutableString * string = [[NSMutableString alloc] initWithFormat:@"telprompt://%@",phoneNum];
    return [DeviceInfoUtils openUrlWithUrlString:string];
}
/** 在 AppStore 打开接单易 */
+ (BOOL)openJDYAtAppStore {
    NSString* appstoreUrlString =@"itms-apps://itunes.apple.com/cn/app/id1004977556?mt=8";
    return [DeviceInfoUtils openUrlWithUrlString:appstoreUrlString];
}
/** 在AppStore 打开接单易评价 */
+ (BOOL)openJDYCommandAtAppStore {
    NSString*appstoreUrlString = [NSString stringWithFormat:
                                  @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=1004977556"];
    return [DeviceInfoUtils openUrlWithUrlString:appstoreUrlString];
}
/** 用 Safari 打开链接 */
+ (BOOL)openSafariWithUrl:(NSString *)url {
    // 把https://带上
    if (![url containsString:@"https"]) {
        url = [NSString stringWithFormat:@"https://%@",url];
    }
    return [DeviceInfoUtils openUrlWithUrlString:url];
}
/**
 * 打开链接，遵守Apple 协议，可以打开电话、网页、APP 等 */
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
            NSLog(@"can not open");
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

/** 是否是 iPhoneX 系列
 * 方式一、通过设备型号判断，这里要注意模拟器无法判断的情况
 * 方式二： 通过设备尺寸判断设备型号时需要注意设备横竖屏，但当手机处于水平状态时（FaceUp、FaceDown）无法判断设备横竖屏状态，所以可以通过尺寸中最大的那个值是否符合来判断
 * 方式三：通过安全区域判断，iPhoneX 系列手机keyWindow 的 safeAreaInsets值为：
 竖屏：{top: 44, left: 0, bottom: 34, right: 0}，
 横屏模式：{top: 0, left: 44, bottom: 21, right: 44}，
 可以判断底部值是否为 34 或 21来判断
 注意：该方法必须在 keyWindow 初始化之后才可以使用
 * 其它：通过状态栏UIStatusBar高度的方式，无法判断横屏和模拟器的情况。通过 FaceID 的方式，也有很多限制，就算了。
 */
+ (BOOL)isIPhoneXSeries {
    BOOL iPhoneXSeries = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        iPhoneXSeries = NO;
    }
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.bottom > 0.0) {
            iPhoneXSeries = YES;
        }
    }
    return iPhoneXSeries;
}

/** 检测设备型号
 * 通过设备型号判断 #import <sys/utsname.h>，这里要注意模拟器无法判断的情况
 */
+ (NSString*)deviceModelName {
    NSString * deviceModel = @"";
    if ([DeviceInfoUtils isSimulator]) {
        deviceModel = NSProcessInfo.processInfo.environment[@"SIMULATOR_MODEL_IDENTIFIER"];
    } else {
        struct utsname systemInfo;
        uname(&systemInfo);
        // NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
        /** 在模拟器中的值是 i386 或 x86_64 */
        deviceModel = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    }
    if([deviceModel isEqualToString:@"iPhone1,1"]) return @"iPhone";
    
    if([deviceModel isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    
    if([deviceModel isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    
    if([deviceModel isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    if([deviceModel isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    if([deviceModel isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    
    if([deviceModel isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    
    if([deviceModel isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    if([deviceModel isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    
    if([deviceModel isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
    if([deviceModel isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
    
    if([deviceModel isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
    if([deviceModel isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
    
    if([deviceModel isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    
    if([deviceModel isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    
    if([deviceModel isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    
    if([deviceModel isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    
    if([deviceModel isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    
    if([deviceModel isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    if([deviceModel isEqualToString:@"iPhone9,3"]) return @"iPhone 7";
    
    if([deviceModel isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    if([deviceModel isEqualToString:@"iPhone9,4"]) return @"iPhone 7 Plus";
    
    if([deviceModel isEqualToString:@"iPhone10,1"]) return @"iPhone 8";
    if([deviceModel isEqualToString:@"iPhone10,4"]) return @"iPhone 8";
    
    if([deviceModel isEqualToString:@"iPhone10,2"]) return @"iPhone 8 Plus";
    if([deviceModel isEqualToString:@"iPhone10,5"]) return @"iPhone 8 Plus";
    
    if([deviceModel isEqualToString:@"iPhone10,3"]) return @"iPhone X";
    if([deviceModel isEqualToString:@"iPhone10,6"]) return @"iPhone X";
    
    if([deviceModel isEqualToString:@"iPhone11,8"]) return @"iPhone XR";
    
    if([deviceModel isEqualToString:@"iPhone11,2"]) return @"iPhone XS";
    
    if([deviceModel isEqualToString:@"iPhone11,4"]) return @"iPhone XS Max";
    if([deviceModel isEqualToString:@"iPhone11,6"]) return @"iPhone XS Max";
    
    if([deviceModel isEqualToString:@"iPhone12,1"]) return @"iPhone 11";
    
    if([deviceModel isEqualToString:@"iPhone12,3"]) return @"iPhone 11 Pro";
    
    if([deviceModel isEqualToString:@"iPhone12,5"]) return @"iPhone 11 Pro Max";
    
    if([deviceModel isEqualToString:@"iPad1,1"]) return @"iPad";
    
    if([deviceModel isEqualToString:@"iPad2,1"]) return @"iPad 2";
    if([deviceModel isEqualToString:@"iPad2,2"]) return @"iPad 2";
    if([deviceModel isEqualToString:@"iPad2,3"]) return @"iPad 2";
    if([deviceModel isEqualToString:@"iPad2,4"]) return @"iPad 2";
    if([deviceModel isEqualToString:@"iPad2,5"]) return @"iPad Mini";
    if([deviceModel isEqualToString:@"iPad2,6"]) return @"iPad Mini";
    if([deviceModel isEqualToString:@"iPad2,7"]) return @"iPad Mini";
    if([deviceModel isEqualToString:@"iPad3,1"]) return @"iPad 3";
    if([deviceModel isEqualToString:@"iPad3,2"]) return @"iPad 3";
    if([deviceModel isEqualToString:@"iPad3,3"]) return @"iPad 3";
    if([deviceModel isEqualToString:@"iPad3,4"]) return @"iPad 4";
    if([deviceModel isEqualToString:@"iPad3,5"]) return @"iPad 4";
    if([deviceModel isEqualToString:@"iPad3,6"]) return @"iPad 4";
    if([deviceModel isEqualToString:@"iPad4,1"]) return @"iPad Air";
    if([deviceModel isEqualToString:@"iPad4,2"]) return @"iPad Air";
    if([deviceModel isEqualToString:@"iPad4,3"]) return @"iPad Air";
    if([deviceModel isEqualToString:@"iPad4,4"]) return @"iPad Mini 2";
    if([deviceModel isEqualToString:@"iPad4,5"]) return @"iPad Mini 2";
    if([deviceModel isEqualToString:@"iPad4,6"]) return @"iPad Mini 2";
    if([deviceModel isEqualToString:@"iPad4,7"]) return @"iPad Mini 3";
    if([deviceModel isEqualToString:@"iPad4,8"]) return @"iPad Mini 3";
    if([deviceModel isEqualToString:@"iPad4,9"]) return @"iPad Mini 3";
    if([deviceModel isEqualToString:@"iPad5,1"]) return @"iPad Mini 4";
    if([deviceModel isEqualToString:@"iPad5,3"]) return @"iPad Air 2";
    if([deviceModel isEqualToString:@"iPad5,4"]) return @"iPad Air 2";
    if([deviceModel isEqualToString:@"iPad6,3"]) return @"iPad Pro 9.7-inch";
    if([deviceModel isEqualToString:@"iPad6,4"]) return @"iPad Pro 9.7-inch";
    if([deviceModel isEqualToString:@"iPad6,7"]) return @"iPad Pro 12.9-inch";
    if([deviceModel isEqualToString:@"iPad6,8"]) return @"iPad Pro 12.9-inch";
    if([deviceModel isEqualToString:@"iPad6,11"]) return @"iPad 5";
    if([deviceModel isEqualToString:@"iPad6,12"]) return @"iPad 5";
    if([deviceModel isEqualToString:@"iPad7,1"]) return @"iPad Pro 12.9-inch 2";
    if([deviceModel isEqualToString:@"iPad7,2"]) return @"iPad Pro 12.9-inch 2";
    if([deviceModel isEqualToString:@"iPad7,3"]) return @"iPad Pro 10.5-inch";
    if([deviceModel isEqualToString:@"iPad7,4"]) return @"iPad Pro 10.5-inch";
    if([deviceModel isEqualToString:@"iPad7,5"]) return @"iPad 6";
    if([deviceModel isEqualToString:@"iPad7,6"]) return @"iPad 6";
    if([deviceModel isEqualToString:@"iPad8,1"]) return @"iPad Pro 11-inch";
    if([deviceModel isEqualToString:@"iPad8,2"]) return @"iPad Pro 11-inch";
    if([deviceModel isEqualToString:@"iPad8,3"]) return @"iPad Pro 11-inch";
    if([deviceModel isEqualToString:@"iPad8,4"]) return @"iPad Pro 11-inch";
    if([deviceModel isEqualToString:@"iPad8,5"]) return @"iPad Pro 12.9-inch 3";
    if([deviceModel isEqualToString:@"iPad8,6"]) return @"iPad Pro 12.9-inch 3";
    if([deviceModel isEqualToString:@"iPad8,7"]) return @"iPad Pro 12.9-inch 3";
    if([deviceModel isEqualToString:@"iPad8,8"]) return @"iPad Pro 12.9-inch 3";
    if([deviceModel isEqualToString:@"iPad11,1"]) return @"iPad Mini 5";
    if([deviceModel isEqualToString:@"iPad11,2"]) return @"iPad Mini 5";
    if([deviceModel isEqualToString:@"iPad11,3"]) return @"iPad Air 3";
    if([deviceModel isEqualToString:@"iPad11,4"]) return @"iPad Air 3";
    
    if([deviceModel isEqualToString:@"iPod1,1"]) return @"iPod Touch";
    if([deviceModel isEqualToString:@"iPod2,1"]) return @"iPod Touch 2";
    if([deviceModel isEqualToString:@"iPod3,1"]) return @"iPod Touch 3";
    if([deviceModel isEqualToString:@"iPod4,1"]) return @"iPod Touch 4";
    if([deviceModel isEqualToString:@"iPod5,1"]) return @"iPod Touch 5";
    if([deviceModel isEqualToString:@"iPod7,1"]) return @"iPod Touch 6";
    if([deviceModel isEqualToString:@"iPod9,1"]) return @"iPod Touch 7";
    
    if([deviceModel isEqualToString:@"i386"]) return @"iPhone Simulator";
    if([deviceModel isEqualToString:@"x86_64"]) return @"iPhone Simulator";
    return deviceModel;
}
/**
 * #import <CoreTelephony/CTCarrier.h>
 #import <CoreTelephony/CTTelephonyNetworkInfo.h> */
+ (NSString *)getIMSI {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [info subscriberCellularProvider];
    /* Mobile Country Code 移动国家码
     * 国际电联（ITU）统一分配 ，中国区是 460 */
    NSString *mcc = [carrier mobileCountryCode];
    /** Mobile Network Code 移动网络号码
     * 用于识别运营商网络 ，由二到三个十进制数组成
     * 中国移动 MNC：00、02、07
     * 中国联通 MNC：01、06、09
     * 中国电信 MNC：03、05、11 */
    NSString *mnc = [carrier mobileNetworkCode];
    NSString *imsi = [NSString stringWithFormat:@"%@%@", mcc, mnc];
    return imsi;
}
/** 获取运营商信息
 * #import <CoreTelephony/CTCarrier.h>
 #import <CoreTelephony/CTTelephonyNetworkInfo.h>
 */
+ (NSString *)getOperatorInfo {
    // 获取本机运营商名称
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [info subscriberCellularProvider];
    // 当前手机所属运营商名称
    NSString *mobile;
    // 先判断有没有SIM卡，如果没有则不获取本机运营商
    if (!carrier.isoCountryCode) {
        NSLog(@"没有SIM卡");
        mobile = @"无运营商";
    } else {
        mobile = [carrier carrierName];
    }
    return mobile;
}

/** 当前设备是否越狱
 * #import <sys/stat.h> */
+ (BOOL)isDevicePrisionBreak {
    // 过滤模拟器检测
    if ([DeviceInfoUtils isSimulator]) {
        return NO;
    }
    // 常见越狱文件，攻击者可能更改这些路径
    NSArray * prisionBreakPathes = @[
                                     @"/Applications/Cydia.app",
                                     @"/Library/MobileSubstrate/MobileSubstrate.dylib",
                                     @"/bin/bash",
                                     @"/usr/sbin/sshd",
                                     @"/etc/apt"
                                     ];
    for (int i = 0; i < prisionBreakPathes.count; i++) {
        // 是否存在越狱文件
        if ([[NSFileManager defaultManager] fileExistsAtPath:prisionBreakPathes[i]]) {
            return YES;
        }
    }
    // 查看 cydia 是否注册 URL Scheme，攻击者不一定会注册，也可能更改其它应用的 URL Sceheme
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]]) {
        return YES;
    }
    // 读取系统所有的应用名称，攻击者可能 hook NSFileManager 方法
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/User/Applications/"]) {
        // NSArray *applist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/User/Applications/" error:nil];
        return YES;
    }
    struct stat stat_info;
    // 使用stat系列函数检测Cydia等工具，攻击者可能会利用 Fishhook原理 hook了stat
    if (0 == stat("/Applications/Cydia.app", &stat_info)) {
        return YES;
    }
    // 检查 stat 是否出自系统库：`/usr/lib/system/libsystem_kernel.dylib`
    // #import <dlfcn.h>
//    int ret ;
//    Dl_info dylib_info;
//    int (*func_stat)(const charchar *, struct stat *) = stat;
//    if ((ret = dladdr(func_stat, &dylib_info))) {
//        NSLog(@"lib :%s", dylib_info.dli_fname);
//    }
    // 读取环境变量，未被修改返回 null
    char *checkInsertLib = getenv("DYLD_INSERT_LIBRARIES");
    if (checkInsertLib) {
        return YES;
    }
    return NO;
}
/** 获取手机电量 */
+ (CGFloat)getDeviceBattery {
    // 监视电池剩余电量
    //  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(action1:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    return [[UIDevice currentDevice] batteryLevel];
}
/** 获取手机充电状态 */
+ (NSInteger)getDeviceBatteryStatus {
    // 监视充电状态
    //  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(action2:) name:UIDeviceBatteryStateDidChangeNotification object:nil];
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    return [[UIDevice currentDevice] batteryState];
}

/**
 * 检查当前是否连网
 * #import <SystemConfiguration/SystemConfiguration.h>
 */
+ (BOOL)whetherConnectedNetwork {
    //创建零地址，0.0.0.0的地址表示查询本机的网络连接状态
    struct sockaddr_storage zeroAddress;//IP地址
    bzero(&zeroAddress, sizeof(zeroAddress));//将地址转换为0.0.0.0
    zeroAddress.ss_len = sizeof(zeroAddress);//地址长度
    zeroAddress.ss_family = AF_INET;//地址类型为UDP, TCP, etc.
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    //获得连接的标志
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    //如果不能获取连接标志，则不能连接网络，直接返回
    if (!didRetrieveFlags) {
        return NO;
    }
    //根据获得的连接标志进行判断
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (isReachable && !needsConnection) ? YES : NO;
}

+ (NSString *)getIPAddress {
    NSString *address = @"";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

/** 获取 WIFI 信息
 * #import <SystemConfiguration/CaptiveNetwork.h>
 * 需要在 AppleID 中打开 WIFI 权限，并在项目 Target-->Capabilities中打开WIFI 权限才能使用
 * iOS 13 后该 API 不可用*/
+ (id)getWifiSSIDInfo {
    NSArray *interfaces = (__bridge_transfer id)CNCopySupportedInterfaces();
    id info = nil;
    for (NSString *interfaceName in interfaces) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName);
        if (info && [info count]) {
            break;
        }
    }
    return info;
}
/** 获取 WIFI 名称 */
+ (NSString *)getWifiSSID {
    return (NSString *)[DeviceInfoUtils getWifiSSIDInfo][@"SSID"];
}
/** 获取WIFI的MAC地址 */
+ (NSString *)getWifiBSSID {
    return (NSString *)[DeviceInfoUtils getWifiSSIDInfo][@"BSSID"];
}

@end
