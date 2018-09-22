//
//  LocationCoordUtils.m
//  jiedanyi3
//
//  Created by 张时疫 on 2018/6/29.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "LocationCoordUtils.h"

/**
 看到了很多相关文档，算法不一致也是让人伤脑筋，这里只能做参考
 */
@implementation LocationCoordUtils


/** 地球坐标(gps84) --> 火星坐标(gcj02) */
+ (NSDictionary *)locationMarsFromEarth_earthLat:(double)latitude earthLon:(double)longitude {
  // 首先判断坐标是否属于天朝
  if (![self isInChinaWithlat:latitude lon:longitude]) {
    return @{@"latitude":@(latitude),
             @"longitude":@(longitude)
             };
  }
  double a = 6378245.0;
  double ee = 0.00669342162296594323;
  
  double dLat = [self transform_earth_from_mars_lat_lat:(latitude - 35.0) lon:(longitude - 35.0)];
  double dLon = [self transform_earth_from_mars_lng_lat:(latitude - 35.0) lon:(longitude - 35.0)];
  double radLat = latitude / 180.0 * M_PI;
  double magic = sin(radLat);
  magic = 1 - ee * magic * magic;
  double sqrtMagic = sqrt(magic);
  dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * M_PI);
  dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * M_PI);
  
  double newLatitude = latitude + dLat;
  double newLongitude = longitude + dLon;
  NSDictionary *dic = @{@"latitude":@(newLatitude),
                        @"longitude":@(newLongitude)
                        };
  return dic;
}
+ (BOOL)isInChinaWithlat:(double)lat lon:(double)lon {
  if (lon < 72.004 || lon > 137.8347)
    return NO;
  if (lat < 0.8293 || lat > 55.8271)
    return NO;
  return YES;
}
+ (double)transform_earth_from_mars_lat_lat:(double)y lon:(double)x {
  double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
  ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
  ret += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
  ret += (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0;
  return ret;
}

+ (double)transform_earth_from_mars_lng_lat:(double)y lon:(double)x {
  double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
  ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
  ret += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
  ret += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0;
  return ret;
}

/**
 *  将GCJ-02坐标转换为BD-09坐标 即将高德地图上获取的坐标转换成百度坐标
 */
+ (CLLocationCoordinate2D)gcj02CoordianteToBD09:(CLLocationCoordinate2D)gdCoordinate {
  double x_PI = M_PI * 3000 /180.0;
  double gd_lat = gdCoordinate.latitude;
  double gd_lon = gdCoordinate.longitude;
  double z = sqrt(gd_lat * gd_lat + gd_lon * gd_lon) + 0.00002 * sin(gd_lat * x_PI);
  double theta = atan2(gd_lat, gd_lon) + 0.000003 * cos(gd_lon * x_PI);
  return CLLocationCoordinate2DMake(z * sin(theta) + 0.006, z * cos(theta) + 0.0065);
}

/**
 *  将BD-09坐标转换为GCJ-02坐标 即将百度地图上获取的坐标转换成高德地图的坐标
 */
+ (CLLocationCoordinate2D)bd09CoordinateToGCJ02:(CLLocationCoordinate2D)bdCoordinate {
  double x_PI = M_PI * 3000 /180.0;
  double bd_lat = bdCoordinate.latitude - 0.006;
  double bd_lon = bdCoordinate.longitude - 0.0065;
  double z = sqrt(bd_lat * bd_lat + bd_lon * bd_lon) + 0.00002 * sin(bd_lat * x_PI);
  double theta = atan2(bd_lat, bd_lon) + 0.000003 * cos(bd_lon * x_PI);
  return CLLocationCoordinate2DMake(z * sin(theta), z * cos(theta));
}

@end



