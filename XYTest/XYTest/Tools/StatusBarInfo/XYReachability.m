//
//  XYReachability.m
//  XYTest
//
//  Created by 张时疫 on 2019/7/22.
//  Copyright © 2019 张时疫. All rights reserved.
//

#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <sys/socket.h>
#import <netinet/in.h>

#import <CoreFoundation/CoreFoundation.h>

#import "XYReachability.h"

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#pragma mark IPv6 Support
//Reachability fully support IPv6.  For full details, see ReadMe.md.


NSString *kReachabilityChangedNotification = @"kNetworkReachabilityChangedNotification";


#pragma mark - Supporting functions

#define kShouldPrintReachabilityFlags 1

static void PrintReachabilityFlags(SCNetworkReachabilityFlags flags, const char* comment)
{
#if kShouldPrintReachabilityFlags

    NSLog(@"Reachability Flag Status: %c%c %c%c%c%c%c%c%c %s\n",
          (flags & kSCNetworkReachabilityFlagsIsWWAN)				? 'W' : '-',
          (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',

          (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
          (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
          (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
          (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-',
          comment
          );
#endif
}


static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
#pragma unused (target, flags)
	NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
	NSCAssert([(__bridge NSObject*) info isKindOfClass: [XYReachability class]], @"info was wrong class in ReachabilityCallback");

    XYReachability* noteObject = (__bridge XYReachability *)info;
    // Post a notification to notify the client that the network reachability changed.
    [[NSNotificationCenter defaultCenter] postNotificationName: kReachabilityChangedNotification object: noteObject];
}


#pragma mark - Reachability implementation

@implementation XYReachability
{
	SCNetworkReachabilityRef _reachabilityRef;
}

+ (instancetype)reachabilityWithHostName:(NSString *)hostName
{
	XYReachability* returnValue = NULL;
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
	if (reachability != NULL)
	{
		returnValue= [[self alloc] init];
		if (returnValue != NULL)
		{
			returnValue->_reachabilityRef = reachability;
		}
        else {
            CFRelease(reachability);
        }
	}
	return returnValue;
}


+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress
{
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, hostAddress);

	XYReachability* returnValue = NULL;

	if (reachability != NULL)
	{
		returnValue = [[self alloc] init];
		if (returnValue != NULL)
		{
			returnValue->_reachabilityRef = reachability;
		}
        else {
            CFRelease(reachability);
        }
	}
	return returnValue;
}


+ (instancetype)reachabilityForInternetConnection
{
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
    
    return [self reachabilityWithAddress: (const struct sockaddr *) &zeroAddress];
}

#pragma mark reachabilityForLocalWiFi
//reachabilityForLocalWiFi has been removed from the sample.  See ReadMe.md for more information.
//+ (instancetype)reachabilityForLocalWiFi



#pragma mark - Start and stop notifier

- (BOOL)startNotifier
{
	BOOL returnValue = NO;
	SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};

	if (SCNetworkReachabilitySetCallback(_reachabilityRef, ReachabilityCallback, &context))
	{
		if (SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode))
		{
			returnValue = YES;
		}
	}
    
	return returnValue;
}


- (void)stopNotifier
{
	if (_reachabilityRef != NULL)
	{
		SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
	}
}


- (void)dealloc
{
	[self stopNotifier];
	if (_reachabilityRef != NULL)
	{
		CFRelease(_reachabilityRef);
	}
}


#pragma mark - Network Flag Handling

- (XYNetworkStatus)XYNetworkStatusForFlags:(SCNetworkReachabilityFlags)flags
{
  PrintReachabilityFlags(flags, "XYNetworkStatusForFlags");
  if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
   {
    // The target host is not reachable.
    return XYNetworkStatusNotReachable;
   }
  
  XYNetworkStatus returnValue = XYNetworkStatusNotReachable;
  
  if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
   {
    /*
     If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
     */
    returnValue = XYNetworkStatusWiFi;
   }
  
  if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
       (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
   {
    /*
     ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
     */
    
    if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
     {
      /*
       ... and no [user] intervention is needed...
       */
      returnValue = XYNetworkStatusWiFi;
     }
   }
  
  if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
   {
    /*
     ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
     */
    NSArray *typeStrings2G = @[CTRadioAccessTechnologyEdge, // EDGE是GPRS 到第三代移动通信的过渡，俗称2.75G
                               CTRadioAccessTechnologyGPRS, // GPRS，介于 2G 和 3G 之间，过渡技术，俗称2.5G
                               CTRadioAccessTechnologyCDMA1x // 2G
                               ];
    NSArray *typeStrings3G = @[CTRadioAccessTechnologyHSDPA, // HSDPA，俗称3.5G
                               CTRadioAccessTechnologyWCDMA, // 3G
                               CTRadioAccessTechnologyHSUPA, // HSUPA，3G 到 4G过渡，俗称3.5G
                               CTRadioAccessTechnologyCDMAEVDORev0, // 3G标准
                               CTRadioAccessTechnologyCDMAEVDORevA, // 3G
                               CTRadioAccessTechnologyCDMAEVDORevB, // 3G
                               CTRadioAccessTechnologyeHRPD // HRPD，电信使用的一种 3G 到 4G 的演进技术，俗称 3.75G
                               ];
    NSArray *typeStrings4G = @[CTRadioAccessTechnologyLTE // 接近4G
                               ];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
      CTTelephonyNetworkInfo *teleInfo= [[CTTelephonyNetworkInfo alloc] init];
      NSString *accessString;
      if (@available(iOS 12.0, *)) {
        if (teleInfo && [teleInfo respondsToSelector:@selector(serviceCurrentRadioAccessTechnology)]) {
          NSDictionary *radioDic = [teleInfo serviceCurrentRadioAccessTechnology];
          if (radioDic.allKeys.count) {
            accessString = [radioDic objectForKey:radioDic.allKeys[0]];
          }
        }
      } else {
        accessString = [teleInfo currentRadioAccessTechnology];
      }
      if ([typeStrings4G containsObject:accessString]) {
        return XYNetworkStatusWWAN4G;
      } else if ([typeStrings3G containsObject:accessString]) {
        return XYNetworkStatusWWAN3G;
      } else if ([typeStrings2G containsObject:accessString]) {
        return XYNetworkStatusWWAN2G;
      } else {
        return XYNetworkStatusUnknown;
      }
    } else {
      return XYNetworkStatusUnknown;
    }
   }
  
  return returnValue;
}


- (BOOL)connectionRequired
{
	NSAssert(_reachabilityRef != NULL, @"connectionRequired called with NULL reachabilityRef");
	SCNetworkReachabilityFlags flags;

	if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags))
	{
		return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
	}

    return NO;
}


- (XYNetworkStatus)currentReachabilityStatus
{
	NSAssert(_reachabilityRef != NULL, @"currentXYNetworkStatus called with NULL SCNetworkReachabilityRef");
	XYNetworkStatus returnValue = XYNetworkStatusNotReachable;
	SCNetworkReachabilityFlags flags;
    
	if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags))
	{
        returnValue = [self XYNetworkStatusForFlags:flags];
	}
    
	return returnValue;
}


@end
