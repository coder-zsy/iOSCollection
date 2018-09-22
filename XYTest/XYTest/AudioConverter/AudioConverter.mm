//
//  AudioConverter.mm
//  XYTest
//
//  Created by 张时疫 on 2018/7/4.
//  Copyright © 2018年 张时疫. All rights reserved.
//

#import "AudioConverter.h"
#import "amrFileCodec.h"

@implementation AudioConverter

+ (void)convertAmrToWavAtPath:(NSString *)amrFilePath wavSavePath:(NSString *)resultSavePath asynchronize:(BOOL)asynchronize completion:(void(^)(BOOL success, NSString *resultPath))completion
{
    if (asynchronize) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL result = DecodeAMRFileToWAVEFile([amrFilePath cStringUsingEncoding:NSASCIIStringEncoding], [resultSavePath cStringUsingEncoding:NSASCIIStringEncoding]);
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(result, [resultSavePath copy]);
                });
            }
        });
    } else {
        BOOL result = DecodeAMRFileToWAVEFile([amrFilePath cStringUsingEncoding:NSASCIIStringEncoding], [resultSavePath cStringUsingEncoding:NSASCIIStringEncoding]);
        if (completion) {
            completion(result, [resultSavePath copy]);
        }
    }
}

+ (void)convertWavToAmrAtPath:(NSString *)wavFilePath amrSavePath:(NSString *)resultSavePath asynchronize:(BOOL)asynchronize completion:(void(^)(BOOL success, NSString *resultPath))completion
{
    if (asynchronize) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL result = EncodeWAVEFileToAMRFile([wavFilePath cStringUsingEncoding:NSASCIIStringEncoding], [resultSavePath cStringUsingEncoding:NSASCIIStringEncoding], 1, 16);
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(result, [resultSavePath copy]);
                });
            }
        });
    } else {
        BOOL result = EncodeWAVEFileToAMRFile([wavFilePath cStringUsingEncoding:NSASCIIStringEncoding], [resultSavePath cStringUsingEncoding:NSASCIIStringEncoding], 1, 16);
        if (completion) {
            completion(result, [resultSavePath copy]);
        }
    }
}

@end
