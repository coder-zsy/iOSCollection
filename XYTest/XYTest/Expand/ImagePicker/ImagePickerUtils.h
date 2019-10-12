//
//  ImagePickerUtils.h
//  jiedanyi3
//
//  Created by 张时疫 on 2019/4/11.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImagePickerUtils : NSObject

/**
 * 创建 App 同名相册
 * 返回相册对象 */
+ (PHAssetCollection *)getCustomCollection;

/**
 * 保存图片到图库
 * 返回图片资源对象
 * */
+ (PHFetchResult<PHAsset *> *)saveImageToAlbum:(nonnull NSArray<UIImage *> *)images;

/**
 * 将图片保存到自定义相册(App 同名相册)
 * */
+ (void)saveImageToAlbum:(nonnull NSArray<UIImage *> *)images callback:(void (^)(PHFetchResult<PHAsset *> *imageAssets, NSError *error, NSString *errorMsg))callback;

/**
 * 获取图库中最后一张保存的图片
 */
+ (PHAsset *)latestAsset;

/**
 * 根据 AVURLAsset 导出视频，并获取视频相关属性信息
 */
+ (void)exportVideoWithAsset:(AVURLAsset *)videoAsset success:(void (^)(NSDictionary * resultDic))success failure:(void (^)(NSString *errorMessage, NSError *error))failure;

/**
 * 根据 PHAsset 导出视频，并获取视频相关属性信息
 */
+ (void)exportVideo:(PHAsset *)pickedAsset success:(void(^)(NSDictionary *dict))success fail:(void (^)(NSString *errorMessage, NSError *error))failure;

/**
 * UIImagePickerControllerReferenceURL 获取 URL 后可使用此方法获取图片信息
 */
+ (void)getImageAssetFromImageAssetUrl:(NSURL *)imageAssetUrl;

/**
 * UIImage 和 NSURL获取图片信息
 * url 可能为空, image不能为空
 */
+ (NSDictionary *)exportImageInfoWithImage:(UIImage * _Nonnull)image URL:(NSURL * _Nullable)url;

/**
 * 根据 PHAsset 导出图片，并获取图片相关属性信息
 */
+ (void)exportImageWithAsset:(PHAsset *)asset success:(void(^)(NSDictionary *dict))success fail:(void (^)(NSString * errorMessage))fail;

/**
 * 将图片保存到相册
 */
+ (void)saveImageToAlbum:(UIImage *)image success:(void (^)(NSURL * url))saveSuccess fail:(void (^)(NSString * errMsg))fail;

/**
 * 获取文件的大小，返回单位是Byte。
 */
+ (CGFloat)getFileSize:(NSString *)path;

/**
 * 获取视频文件的时长
 */
+ (CGFloat)getVideoLength:(NSURL *)URL;

@end

NS_ASSUME_NONNULL_END
