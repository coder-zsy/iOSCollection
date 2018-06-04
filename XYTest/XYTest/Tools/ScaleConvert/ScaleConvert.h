//
//  ScaleConvert.h
//  FleaBag
//
//  Created by 张时疫 on 16/8/27.
//  Copyright © 2016年 ZhangShiYi. All rights reserved.
//

/**待学习测试内容：
 *  http://www.cnblogs.com/Mr-Ygs/p/4876975.html
 */

#import <Foundation/Foundation.h>
/**
 *  Tool：进制转换
 */
@interface ScaleConvert : NSObject

/**
 *  将十六进制转化为二进制 （NSString(hex) -- > NSString(binary)）
 */
+ (NSString *)getBinaryByhex:(NSString *)hex;

/**
 *  将十六进制转化为NSData(十进制)  （NSString(hex) -- >  NSData）
 */
+ (NSData *)hexToData:(NSString *)hexString ;
/**
 *  将十六进制字符串转化为NSData （NSString(hex) -- > NSData）
 */
+ (NSData *)convertHexStrToData:(NSString *)str;
///**
// *  将NSData转化为十六进制字符串（NSData -- > NSString(hex)）
// */
//+ (NSString *)convertDataToHexStr:(NSData *)data;

/**
 *  将十进制转化为二进制（uint16_t -- > NSString(binary)）
 *
 *  @param tmpid  十进制数
 *  @param length 返回二进制字符串的长度
 */
+ (NSString *)decimalTOBinary:(uint16_t)tmpid backLength:(int)length;

/**
 *  将十进制转化为十六进制 （uint16_t -- > NSString(hex)）
 *
 *  @param tmpid 十进制数
 */
+ (NSString *)ToHex:(uint16_t)tmpid;

/**
 *  将二进制数据转换成十六进制字符串 （NSDatan(binary) -- > NSString(hex) ）
 *
 *  @param data 二进制数据
 */
+ (NSString *)data2Hex:(NSData *)data;

@end
