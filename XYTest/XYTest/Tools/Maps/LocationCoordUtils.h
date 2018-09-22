//
//  LocationCoordUtils.h
//  jiedanyi3
//
//  Created by 张时疫 on 2018/6/29.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import<CoreLocation/CoreLocation.h>

@interface LocationCoordUtils : NSObject

/** 地球坐标--> 火星坐标 */
+ (NSDictionary *)locationMarsFromEarth_earthLat:(double)latitude earthLon:(double)longitude;

/**
 *  将GCJ-02坐标转换为BD-09坐标 即将高德地图上获取的坐标转换成百度坐标
 */
+ (CLLocationCoordinate2D)gcj02CoordianteToBD09:(CLLocationCoordinate2D)gdCoordinate;

/**
 *  将BD-09坐标转换为GCJ-02坐标 即将百度地图上获取的坐标转换成高德地图的坐标
 */
+ (CLLocationCoordinate2D)bd09CoordinateToGCJ02:(CLLocationCoordinate2D)bdCoordinate;

@end
