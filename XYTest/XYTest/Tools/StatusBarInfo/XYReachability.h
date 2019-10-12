//
//  XYReachability.h
//  XYTest
//
//  Created by 张时疫 on 2019/7/22.
//  Copyright © 2019 张时疫. All rights reserved.
//

// 官方 demo https://developer.apple.com/library/archive/samplecode/Reachability/Listings/Reachability_Reachability_h.html#//apple_ref/doc/uid/DTS40007324-Reachability_Reachability_h-DontLinkElementID_8

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>


typedef NS_ENUM(NSUInteger, XYNetworkStatus) {
    XYNetworkStatusNotReachable = 0,
    XYNetworkStatusUnknown = 1,
    XYNetworkStatusWWAN2G = 2,
    XYNetworkStatusWWAN3G = 3,
    XYNetworkStatusWWAN4G = 4,
    XYNetworkStatusWiFi = 5,
};
#pragma mark IPv6 Support
//Reachability fully support IPv6.  For full details, see ReadMe.md.


extern NSString *kReachabilityChangedNotification;


@interface XYReachability : NSObject

/*!
 * Use to check the reachability of a given host name.
 */
+ (instancetype)reachabilityWithHostName:(NSString *)hostName;

/*!
 * Use to check the reachability of a given IP address.
 */
+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress;

/*!
 * Checks whether the default route is available. Should be used by applications that do not connect to a particular host.
 */
+ (instancetype)reachabilityForInternetConnection;


#pragma mark reachabilityForLocalWiFi
//reachabilityForLocalWiFi has been removed from the sample.  See ReadMe.md for more information.
//+ (instancetype)reachabilityForLocalWiFi;

/*!
 * Start listening for reachability notifications on the current run loop.
 */
- (BOOL)startNotifier;
- (void)stopNotifier;

- (XYNetworkStatus)currentReachabilityStatus;

/*!
 * WWAN may be available, but not active until a connection has been established. WiFi may require a connection for VPN on Demand.
 */
- (BOOL)connectionRequired;

@end


