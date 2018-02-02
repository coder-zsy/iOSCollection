//
//  PermissionCheckTools.h
//  XYTest
//
//  Created by 张时疫 on 2018/1/30.
//  Copyright © 2018年 张时疫. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
typedef NS_ENUM(NSInteger , XYAuthorizationStatus) {
    XYAuthorizationStatusNotDetermined,			//未请求授权
    XYAuthorizationStatusRestricted,					//无相关权限，如：家长控制
    XYAuthorizationStatusUnable,							//服务不可用
    XYAuthorizationStatusDenied,							//已拒绝访问
    XYAuthorizationStatusWhenInUse,					//拥有 app 使用时的权限
    XYAuthorizationStatusAuthorized,					//拥有所有权限
};

typedef void(^AuthorizationStatusBlock)(XYAuthorizationStatus status);

@interface PermissionCheckTools : NSObject


/**这里使用单例模式主要是因为：
 * 1、获取定位权限时，定位对象会在请求定位权限时被释放，导致请求定位权限的弹框一闪而逝
 * 2、也可以使用 AppDelegate 作为单例的承载对象 */
singleton_interface(PermissionCheckTools);

/**
 * 打开设置界面*/
- (void)openPermissionSetting ;

/** 获取相册权限
 * #import <Photos/Photos.h>
 * 被拒绝或关闭授权时，无法再次请求授权，只能提示用户主动开启*/
- (void)checkPhotoAuthorWithCallback:(AuthorizationStatusBlock)callback ;

// 获取相机权限
- (void)checkCameraAuthorWithCallback:(AuthorizationStatusBlock)callback ;

/*检查麦克风权限
 * AVAudioSessionRecordPermissionUndetermined = 'undt’,// 未获取权限
 * AVAudioSessionRecordPermissionDenied = 'deny’,//拒绝授权
 * AVAudioSessionRecordPermissionGranted = ‘grant’//同意授权*/
- (void)checkMicrophoneAuthorWithCallback:(AuthorizationStatusBlock)callback ;

/**
 * 获取通讯录权限*/
- (void)checkAddressBookAuthorWithCallback:(AuthorizationStatusBlock)callback;

- (void)checkNotificationAuthorWithCallback:(AuthorizationStatusBlock)callback;

- (void)checkNetworkAuthorWithCallback:(AuthorizationStatusBlock)callback;

/**定位权限检测
 * 在 info.plist 中增加以下此段，以说明请求权限的原因
 * 1.NSLocationAlwaysAndWhenInUseUsageDescription
 * 2.NSLocationWhenInUseUsageDescription
 * 定位权限申请*/
- (void)checkLocationAuthorAuthorWithType:(XYAuthorizationStatus)status callback:(AuthorizationStatusBlock)callback ;


@end
