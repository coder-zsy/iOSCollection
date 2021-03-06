//
//  AppDelegate.m
//  Test
//
//  Created by 张时疫 on 2018/1/28.
//  Copyright © 2018年 张时疫. All rights reserved.
//

#import "AppDelegate.h"
#import "PermissionUtils.h"
#import "SettingViewController.h"

#import "BaseTabbarController.h"
#import "BaseNavigationViewController.h"

@interface AppDelegate ()
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//     [UIApplication sharedApplication].statusBarHidden = YES;
//    [UIApplication sharedApplication].statusBarStyle =  UIStatusBarStyleLightContent;
    SettingViewController * settingVC = [[SettingViewController alloc] init];
    BaseNavigationViewController * nav = [[BaseNavigationViewController alloc] initWithRootViewController:settingVC];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    BaseTabbarController * tabbarController = [[BaseTabbarController alloc] init];
    
    self.window.rootViewController = tabbarController;
    [self.window makeKeyAndVisible];
    
    NSString * testStr = @"{\"url\":\"https://www.baidu.com\",\"params\":{\"param1\":\"test\",\"param2\":34,\"param3\":[\"aaa\",\"bbb\"],\"param4\":{\"test\":\"aa\"}}}";
    
    UIWebView * tempWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString * userAgent = [tempWebView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    if (![userAgent containsString:@"towkershop"] || ![userAgent containsString:@"mmb_v2.0"]) {
        NSString * ua = [NSString stringWithFormat:@"%@ %@ %@",
                        userAgent,@"towkershop",
                        @"mmb_v2.0"];
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent" : ua, @"User-Agent" : ua}];
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
//- (CLLocationManager *)locationManager {
//    if (!_locationManager) {
//        _locationManager = [[CLLocationManager alloc] init];
//        _locationManager.delegate = self;
//    }
//    return _locationManager;
//}
//
//- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
//    __block XYAuthorizationStatus state = XYAuthorizationStatusNotDetermined;
//    switch (status) {
//        case kCLAuthorizationStatusNotDetermined:{
//            //未请求授权
//            state = XYAuthorizationStatusNotDetermined;
//        }
//            break;
//        case kCLAuthorizationStatusRestricted:{
//            //无相关权限，如：家长控制
//            state = XYAuthorizationStatusRestricted;
//        }
//            break;
//        case kCLAuthorizationStatusDenied:{
//            //已拒绝访问
//            state = XYAuthorizationStatusDenied;
//        }
//            break;
//        case kCLAuthorizationStatusAuthorizedAlways:{
//            //已获取授权，任何时候都可以使用(前台、后台)
//            state = XYAuthorizationStatusAuthorized;
//        }
//            break;
//        case kCLAuthorizationStatusAuthorizedWhenInUse:{
//            //仅授权了在应用程序使用时使用
//            state = XYAuthorizationStatusWhenInUse;
//        }
//            break;
//        default:
//            break;
//    }
////    self.locationStatusBlock(state);
//}

@end
