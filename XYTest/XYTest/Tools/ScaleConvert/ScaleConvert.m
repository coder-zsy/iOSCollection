//
//  ScaleConvert.m
//  FleaBag
//
//  Created by 张时疫 on 16/8/27.
//  Copyright © 2016年 ZhangShiYi. All rights reserved.
//

#import "ScaleConvert.h"

@implementation ScaleConvert
/**
 *  将十六进制转化为二进制 （NSString(hex) -- > NSString(binary)）
 */
+ (NSString *)getBinaryByhex:(NSString *)hex {
    NSMutableDictionary  *hexDic = [[NSMutableDictionary alloc] init];
    hexDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    [hexDic setObject:@"0000" forKey:@"0"];
    [hexDic setObject:@"0001" forKey:@"1"];
    [hexDic setObject:@"0010" forKey:@"2"];
    [hexDic setObject:@"0011" forKey:@"3"];
    [hexDic setObject:@"0100" forKey:@"4"];
    [hexDic setObject:@"0101" forKey:@"5"];
    [hexDic setObject:@"0110" forKey:@"6"];
    [hexDic setObject:@"0111" forKey:@"7"];
    [hexDic setObject:@"1000" forKey:@"8"];
    [hexDic setObject:@"1001" forKey:@"9"];
    [hexDic setObject:@"1010" forKey:@"A"];
    [hexDic setObject:@"1011" forKey:@"B"];
    [hexDic setObject:@"1100" forKey:@"C"];
    [hexDic setObject:@"1101" forKey:@"D"];
    [hexDic setObject:@"1110" forKey:@"E"];
    [hexDic setObject:@"1111" forKey:@"F"];
//    NSMutableString *binaryString = [[NSMutableString alloc] init];
    NSString *binaryString ;
    for (int i = 0; i < [hex length]; i++) {
        NSRange rage;
        rage.length = 1;
        rage.location = i;
        NSString *key = [hex substringWithRange:rage];
        //NSLog(@"%@",[NSString stringWithFormat:@"%@",[hexDic objectForKey:key]]);
        binaryString = [NSString stringWithFormat:@"%@%@",binaryString,[NSString stringWithFormat:@"%@",[hexDic objectForKey:key]]];
    }
    //NSLog(@"转化后的二进制为:%@",binaryString);
    return binaryString;
}
/**
 *  将十进制转化为二进制（uint16_t -- > NSString(binary)）
 *
 *  @param tmpid  十进制数
 *  @param length 返回二进制字符串的长度
 */
+ (NSString *)decimalTOBinary:(uint16_t)tmpid backLength:(int)length {
    NSString *a = @"";
    while (tmpid) {
        a = [[NSString stringWithFormat:@"%d",tmpid%2] stringByAppendingString:a];
        if (tmpid/2 < 1) {
            break;
        }
        tmpid = tmpid/2 ;
    }
    if (a.length <= length) {
        NSMutableString *b = [[NSMutableString alloc] init];;
        for (int i = 0; i < length - a.length; i++) {
            [b appendString:@"0"];
        }
        a = [b stringByAppendingString:a];
    }
    return a;
}
/**
 *  将十进制转化为十六进制 （uint16_t -- > NSString(hex)）
 *
 *  @param tmpid 十进制数
 */
+ (NSString *)ToHex:(uint16_t)tmpid {
    NSString *nLetterValue;
    NSString *str =@"";
    uint16_t ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig) {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:
                nLetterValue = [NSString stringWithFormat:@"%u",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
    }
    return str;
}

/**
 *  将二进制数据转换成十六进制字符串 （NSDatan(binary) -- > NSString(hex) ）
 *
 *  @param data 二进制数据
 */
+ (NSString *)data2Hex:(NSData *)data {
    if (!data) {
        return nil;
    }
    Byte *bytes = (Byte *)[data bytes];
    NSMutableString *str = [NSMutableString stringWithCapacity:data.length * 2];
    for (int i=0; i < data.length; i++){
        [str appendFormat:@"%0x", bytes[i]];
    }
    return str;
}
/**
 *  将十六进制字符串转化为NSData （NSString(hex) -- > NSData）
 */
+ (NSData *)convertHexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}
///**
// *  将NSData转化为十六进制字符串（NSData -- > NSString(hex)）
// */
//+ (NSString *)convertDataToHexStr:(NSData *)data {
//    if (!data || [data length] == 0) {
//        return @"";
//    }
//    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
//    
//    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
//        unsigned char *dataBytes = (unsigned char*)bytes;
//        for (NSInteger i = 0; i < byteRange.length; i++) {
//            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
//            if ([hexStr length] == 2) {
//                [string appendString:hexStr];
//            } else {
//                [string appendFormat:@"0%@", hexStr];
//            }
//        }
//    }];
//    return string;
//}

//十六进制转化为十进制
+ (NSData *)hexToData:(NSString *)hexString {
    int j = 0;
    Byte bytes[4];
    for(int i = 0;i < [hexString length];i++) {
        int int_ch = 0;  // 两位16进制数转化后的10进制数
        
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        
        int int_ch1 = 0;
        
        if(hex_char1 >= '0' && hex_char1 <= '9') {
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
            
        } else if(hex_char1 >= 'A' && hex_char1 <= 'F') {
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
            
        } else {
            int_ch1 = (hex_char1 - 87)*16; //// a 的Ascll - 97
        }
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2 = 0;
        
        if(hex_char2 >= '0' && hex_char2 <= '9') {
            int_ch2 = (hex_char2 - 48); //// 0 的Ascll - 48
            
        } else if(hex_char2 >= 'A' && hex_char2 <= 'F') {
            int_ch2 = hex_char2 - 55; //// A 的Ascll - 65
            
        } else {
            int_ch2 = hex_char2 - 87; //// a 的Ascll - 97
        }
        int_ch = int_ch1+int_ch2;
        
        bytes[j] = int_ch;  //将转化后的数放入Byte数组里
        
        j++;
        
    }
    NSData *newData = [[NSData alloc] initWithBytes:bytes length:4];
    return newData;
}


@end
