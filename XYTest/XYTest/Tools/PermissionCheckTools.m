//
//  PermissionCheckTools.m
//  XYTest
//
//  Created by 张时疫 on 2018/1/30.
//  Copyright © 2018年 张时疫. All rights reserved.
//

#import "PermissionCheckTools.h"

#import <Photos/Photos.h>
#import <CoreLocation/CoreLocation.h>
#import <EventKit/EventKit.h>

//#import <CoreTelephony/CoreTelephonyDefines.h>
@import AddressBook;
@import Contacts;
@import CoreTelephony;

@interface PermissionCheckTools ()<CLLocationManagerDelegate>

@property (nonatomic , strong) AuthorizationStatusBlock locationStatusBlock;
@property (nonatomic , strong) CLLocationManager * locationManager;


@end

@implementation PermissionCheckTools

singleton_implementation(PermissionCheckTools);

- (void)openPermissionSetting {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

#pragma mark --- 相册 ---
/** 获取相册权限
 * #import <Photos/Photos.h>
 * Privacy - Photo Library Usage Description
 * Privacy - Media Library Usage Description
 * 被拒绝或关闭授权时，无法再次请求授权，只能提示用户主动开启*/
- (void)checkPhotoAuthorWithCallback:(AuthorizationStatusBlock)callback {
    __block XYAuthorizationStatus state = XYAuthorizationStatusNotDetermined;
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        // 用户已授权，允许访问
        state = XYAuthorizationStatusAuthorized;
    } else if (status == PHAuthorizationStatusRestricted) {
        NSLog(@"拒绝、关闭授权，请开启相册权限\n 设置 -> 隐私 -> 照片");
        state = XYAuthorizationStatusRestricted;
    } else if (status == PHAuthorizationStatusDenied) {
        state = XYAuthorizationStatusDenied;
    } else {
        //未请求过授权
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusNotDetermined) {
                state = XYAuthorizationStatusNotDetermined;
            } else if (status == PHAuthorizationStatusAuthorized) {
                state = XYAuthorizationStatusAuthorized;
            } else if (status == PHAuthorizationStatusDenied) {
                state = XYAuthorizationStatusDenied;
            } else {
                state = XYAuthorizationStatusRestricted;
            }
        }];
    }
    callback(state);
}
#pragma mark --- 相机 ---
/**获取相机权限
 * Privacy - Camera Usage Description*/
- (void)checkCameraAuthorWithCallback:(AuthorizationStatusBlock)callback {
    __block XYAuthorizationStatus state = XYAuthorizationStatusNotDetermined;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusAuthorized) {
        // 用户已授权，允许访问
        state = XYAuthorizationStatusAuthorized;
    } else if (status == AVAuthorizationStatusRestricted) {
        NSLog(@"拒绝、关闭授权，请开启相机权限\n 设置 -> 隐私 -> 相机");
        state = XYAuthorizationStatusRestricted;
    } else if (status == AVAuthorizationStatusDenied) {
        state = XYAuthorizationStatusDenied;
    } else {
        //未请求过授权
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                state = XYAuthorizationStatusAuthorized;
            } else {
                state = XYAuthorizationStatusDenied;
            }
        }];
    }
    callback(state);
}
#pragma mark --- 麦克风 ---
/*检查麦克风权限
 * Privacy - Microphone Usage Description*/
- (void)checkMicrophoneAuthorWithCallback:(AuthorizationStatusBlock)callback {
    __block XYAuthorizationStatus state = XYAuthorizationStatusNotDetermined;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    AVAudioSessionRecordPermission status = [audioSession recordPermission];
    if (status == AVAudioSessionRecordPermissionDenied) {
        state = XYAuthorizationStatusDenied;
        NSLog(@"拒绝、关闭授权，请开启麦克风权限\n 设置 -> 隐私 -> 麦克风");
    } else if (status == AVAudioSessionRecordPermissionGranted) {
        state = XYAuthorizationStatusAuthorized;
    } else {//status == AVAudioSessionRecordPermissionUndetermined
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                if (granted) {
                    state = XYAuthorizationStatusAuthorized;
                } else {
                    NSLog(@"请开启麦克风访问权限:\n设置 -> 隐私 -> 麦克风");
                    state = XYAuthorizationStatusDenied;
                }
            }];
        }
    }
    callback(state);
}
#pragma mark --- 通讯录 ---
/**
 * 获取通讯录权限*/
- (void)checkAddressBookAuthorWithCallback:(AuthorizationStatusBlock)callback {
    __block XYAuthorizationStatus state = XYAuthorizationStatusNotDetermined;
    /* iOS9.0及以后
     导入头文件 **@import Contacts;**
     检查是否有通讯录权限 */
    if (@available(iOS 9.0, *)) {
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        switch (status) {
            case CNAuthorizationStatusAuthorized: {
                state = XYAuthorizationStatusAuthorized;
            } break;
            case CNAuthorizationStatusDenied:{
                state = XYAuthorizationStatusDenied;
            } break;
            case CNAuthorizationStatusRestricted:{
                state = XYAuthorizationStatusRestricted;
            } break;
            case CNAuthorizationStatusNotDetermined:{
                //查询是否获取通讯录权限
                CNContactStore *contactStore = [[CNContactStore alloc] init];
                [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                    if (granted) {
                        state = XYAuthorizationStatusAuthorized;
                    } else {
                        state = XYAuthorizationStatusDenied;
                    }
                }];
            } break;
            default:break;
        }
    } else {
        /**Fallback on earlier versions
         * @import AddressBook;*/
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        switch (status) {
            case kABAuthorizationStatusNotDetermined:
                //state = XYAuthorizationStatusNotDetermined;
                // 获取通讯录权限
                //ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
                ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, NULL), ^(bool granted, CFErrorRef error) {
                    if (granted) {
                        state = XYAuthorizationStatusAuthorized;
                        //CFRelease(addressBook);
                    } else {
                        state = XYAuthorizationStatusDenied;
                    }});
                break;
            case kABAuthorizationStatusAuthorized:
                state = XYAuthorizationStatusAuthorized;
                break;
            case kABAuthorizationStatusDenied:
                state = XYAuthorizationStatusDenied;
                break;
            case kABAuthorizationStatusRestricted:
                state = XYAuthorizationStatusRestricted;
                break;
            default:
                break;
        }
    }
    callback(state);
}
#pragma mark --- 日历备忘录 ---
/**检查日历和备忘录权限
 * #import <EventKit/EventKit.h>
 * */
- (void)checkEventAuthorWithType:(EKEntityType)eventType  callback:(AuthorizationStatusBlock)callback {
    __block XYAuthorizationStatus state = XYAuthorizationStatusNotDetermined;
    EKAuthorizationStatus EKstatus = [EKEventStore  authorizationStatusForEntityType:eventType];
    switch (EKstatus) {
        case EKAuthorizationStatusNotDetermined:{
            state = XYAuthorizationStatusNotDetermined;
            EKEventStore *store = [[EKEventStore alloc]init];
            [store requestAccessToEntityType:eventType completion:^(BOOL granted, NSError * _Nullable error) {
                if (granted) {
                    state = XYAuthorizationStatusAuthorized;
                } else {
                    state = XYAuthorizationStatusDenied;
                }
                callback(state);
            }];
        }
            break;
        case EKAuthorizationStatusAuthorized:
            state = XYAuthorizationStatusAuthorized;
            callback(state);
            break;
        case EKAuthorizationStatusDenied:
            state = XYAuthorizationStatusDenied;
            callback(state);
            break;
        case EKAuthorizationStatusRestricted:
            state = XYAuthorizationStatusRestricted;
            callback(state);
            break;
        default:
            break;
    }
}

#pragma mark --- 推送通知 ---
- (void)checkNotificationAuthorWithCallback:(AuthorizationStatusBlock)callback {
    BOOL pushEnabled;
    // 设置里的通知总开关是否打开
    BOOL settingEnabled = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
    // 设置里的通知各子项是否都打开
    BOOL subsettingEnabled = [[UIApplication sharedApplication] currentUserNotificationSettings].types != UIUserNotificationTypeNone;
    pushEnabled = settingEnabled && subsettingEnabled;
    //当前打开的权限：
    UIUserNotificationSettings *settings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    switch (settings.types) {
        case UIUserNotificationTypeNone:
            NSLog(@"None");
            break;
        case UIUserNotificationTypeAlert:
            NSLog(@"Alert Notification");
            break;
        case UIUserNotificationTypeBadge:
            NSLog(@"Badge Notification");
            break;
        case UIUserNotificationTypeSound:
            NSLog(@"sound Notification'");
            break;
            
        default:
            break;
    }
    
    //请求权限
    UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    
}
#pragma mark --- 网络 ---
- (void)checkNetworkAuthorWithCallback:(AuthorizationStatusBlock)callback {
    /**
     使用时需要注意的关键点：
     
     CTCellularData  只能检测蜂窝权限，不能检测WiFi权限。
     一个CTCellularData实例新建时，restrictedState是kCTCellularDataRestrictedStateUnknown，
     之后在cellularDataRestrictionDidUpdateNotifier里会有一次回调，此时才能获取到正确的权限状态。
     当用户在设置里更改了app的权限时，cellularDataRestrictionDidUpdateNotifier会收到回调，如果要停止监听，
     必须将cellularDataRestrictionDidUpdateNotifier设置为nil。
     赋值给cellularDataRestrictionDidUpdateNotifier的block并不会自动释放，
     即便你给一个局部变量的CTCellularData实例设置监听，当权限更改时，还是会收到回调，所以记得将block置nil。
     */
    if (@available(iOS 9.0, *)) {
        CTCellularData *cellularData = [[CTCellularData alloc] init];
        //获取联网状态 switch (state)
        cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState state) {
            switch (state) {
                case kCTCellularDataRestricted: {
                    
                } break;
                case kCTCellularDataNotRestricted: {
                    
                } break;
                    //未知，第一次请求
                case kCTCellularDataRestrictedStateUnknown: {
                    
                } break;
                default: break;
            }
        };
    } else {
        // Fallback on earlier versions
    }
}
#pragma mark --- 定位 ---
/**定位权限检测
 * 在 info.plist 中增加以下此段，以说明请求权限的原因
 * 1.Privacy - Location Always and When In Use Usage Description
 * 2.Privacy - Location When In Use Usage Description
 * 3.Privacy - Location Always Usage Description
 * 定位权限申请*/
- (void)checkLocationAuthorAuthorWithType:(XYAuthorizationStatus)status callback:(AuthorizationStatusBlock)callback {
    self.locationStatusBlock = callback;
    __block XYAuthorizationStatus state = XYAuthorizationStatusNotDetermined;
    if (![CLLocationManager locationServicesEnabled]) {
        state = XYAuthorizationStatusUnable;
        self.locationStatusBlock(state);
        return;
    }
    CLAuthorizationStatus curStatus = [CLLocationManager authorizationStatus];
    switch (curStatus) {
        case kCLAuthorizationStatusNotDetermined:{
            //未请求授权
            state = XYAuthorizationStatusNotDetermined;
            //requestWhenInUseAuthorization
            //只能请求一次，以后再请求无效，需要主动弹出弹框提示用户手动打开
            //requestAlwaysAuthorization
            if (status == XYAuthorizationStatusWhenInUse) {
                [self.locationManager requestWhenInUseAuthorization];
            } else if (status == XYAuthorizationStatusAuthorized) {
                [self.locationManager requestAlwaysAuthorization];
            } else {
                NSLog(@"好好传值不要闹！！");
            }
        }
            break;
        case kCLAuthorizationStatusRestricted:{
            //无相关权限，如：家长控制
            state = XYAuthorizationStatusRestricted;
            self.locationStatusBlock(state);
        }
            break;
        case kCLAuthorizationStatusDenied:{
            //已拒绝访问
            state = XYAuthorizationStatusDenied;
            self.locationStatusBlock(state);
        }
            break;
        case kCLAuthorizationStatusAuthorizedAlways:{
            //已获取授权，任何时候都可以使用(前台、后台)
            state = XYAuthorizationStatusAuthorized;
            self.locationStatusBlock(state);
        }
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:{
            //仅授权了在应用程序使用时使用
            state = XYAuthorizationStatusWhenInUse;
            self.locationStatusBlock(state);
        }
            break;
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    __block XYAuthorizationStatus state = XYAuthorizationStatusNotDetermined;
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:{
            //未请求授权
            state = XYAuthorizationStatusNotDetermined;
        }
            break;
        case kCLAuthorizationStatusRestricted:{
            //无相关权限，如：家长控制
            state = XYAuthorizationStatusRestricted;
        }
            break;
        case kCLAuthorizationStatusDenied:{
            //已拒绝访问
            state = XYAuthorizationStatusDenied;
        }
            break;
        case kCLAuthorizationStatusAuthorizedAlways:{
            //已获取授权，任何时候都可以使用(前台、后台)
            state = XYAuthorizationStatusAuthorized;
        }
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:{
            //仅授权了在应用程序使用时使用
            state = XYAuthorizationStatusWhenInUse;
        }
            break;
        default:
            break;
    }
    self.locationStatusBlock(state);
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}
@end

