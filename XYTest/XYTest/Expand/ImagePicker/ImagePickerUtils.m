//
//  ImagePickerUtils.m
//  jiedanyi3
//
//  Created by 张时疫 on 2019/4/11.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "ImagePickerUtils.h"

@implementation ImagePickerUtils

/**
 * 创建 App 同名相册
 * 返回相册对象 */
+ (PHAssetCollection*)getCustomCollection {
    //获取App名字
    NSString *title = [NSBundle mainBundle].infoDictionary[(__bridge NSString*)kCFBundleNameKey];
    //抓取所有【自定义相册】
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    // 查询当前App对应的自定义相册
    for (PHAssetCollection *collection in collections) {
        if ([collection.localizedTitle isEqualToString:title]) {
            return collection;
        }
    }
    //当前对应的app相册没有被创建
    NSError *error = nil;
    __block NSString *createCollectionID = nil;
    BOOL isPerformSuccess = [[PHPhotoLibrary sharedPhotoLibrary]performChangesAndWait:^{
        //创建一个【自定义相册】(需要这个block执行完，相册才创建成功)
        createCollectionID = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title].placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    if (!isPerformSuccess || error) {
        NSLog(@"创建相册失败");
        return nil;
    }
    // 根据唯一标识，获得刚才创建的相册
    PHAssetCollection *createCollection = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createCollectionID] options:nil].firstObject;
    return createCollection;
}

/**
 * 保存图片到图库
 * 获取图片资源对象
 * */
+ (PHFetchResult<PHAsset *> *)saveImageToAlbum:(nonnull NSArray<UIImage *> *)images {
    // 同步执行修改操作
    NSError *error = nil;
    NSMutableArray *imageIds = [[NSMutableArray alloc] init];
    // 保存图片到【相机胶卷】
    BOOL isPerformSuccess = [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //写入图片到相册
            PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:obj];
            //记录本地标识，等待完成后取到相册中的图片对象
            [imageIds addObject:req.placeholderForCreatedAsset.localIdentifier];
        }];
    } error:&error];
    
    if (!isPerformSuccess || error) {
        NSLog(@"保存失败");
        return nil;
    }
    // 获取相片
    PHFetchResult<PHAsset *> *imageAssets = [PHAsset fetchAssetsWithLocalIdentifiers:imageIds options:nil];
    return imageAssets;
}

/**
 * 将图片保存到自定义相册
 * */
+ (void)saveImageToAlbum:(nonnull NSArray<UIImage *> *)images callback:(void (^)(PHFetchResult<PHAsset *> *imageAssets, NSError *error, NSString *errorMsg))callback {
    NSError *error = nil;
    NSString *errorMsg = nil;
    
    // 保存图片到【图库】
    PHFetchResult<PHAsset *> *imageAssets = [ImagePickerUtils saveImageToAlbum:images];
    // 创建【自定义相册】
    PHAssetCollection * assetCollection = [ImagePickerUtils getCustomCollection];
    if (!imageAssets) {
        errorMsg = @"图片保存失败";
    } else if (!assetCollection) {
        errorMsg = @"创建相册失败";
    } else {
        // 将保存到【图库】的图片引用到【自定义相册】
        BOOL isPerformSuccess = [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
            PHAssetCollectionChangeRequest *requtes = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
            [requtes insertAssets:imageAssets atIndexes:[NSIndexSet indexSetWithIndex:0]];
        } error:&error];
        if (!isPerformSuccess || error) {
            errorMsg = @"将图片保存到自定义相册失败";
        }
    }
    callback(imageAssets, error, errorMsg);
}
/**
 * 获取图库中最后一张保存的图片
 */
+ (PHAsset *)latestAsset {
    // 获取所有资源的集合，并按资源的创建时间排序
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    return [assetsFetchResults firstObject];
}
/**
 * 压缩、导出视频
 */
+ (void)exportVideoWithAsset:(AVURLAsset *)videoAsset success:(void (^)(NSDictionary * resultDic))success failure:(void (^)(NSString *errorMessage, NSError *error))failure {
//      NSArray *presets = [AVAssetExportSession exportPresetsCompatibleWithAsset:videoAsset];
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:videoAsset presetName:AVAssetExportPresetMediumQuality];
    
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss-SSS"];
    NSString *outputPath = [NSHomeDirectory() stringByAppendingFormat:@"/tmp/XYProof-%@.mp4", [formater stringFromDate:[NSDate date]]];
    session.outputURL = [NSURL fileURLWithPath:outputPath];
    session.shouldOptimizeForNetworkUse = true;
    
    NSArray *supportedTypeArray = session.supportedFileTypes;
    if (supportedTypeArray.count == 0) {
        if (failure) {
            failure(@"该视频类型暂不支持导出", nil);
        }
        XYLog(@"No supported file types 视频类型暂不支持导出");
        return;
    } else if ([supportedTypeArray containsObject:AVFileTypeMPEG4]) {
        session.outputFileType = AVFileTypeMPEG4;
    } else {
        session.outputFileType = [supportedTypeArray objectAtIndex:0];
    }
    
    //  if (![[NSFileManager defaultManager] fileExistsAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/tmp"]]) {
    //    [[NSFileManager defaultManager] createDirectoryAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/tmp"] withIntermediateDirectories:YES attributes:nil error:nil];
    //  }
    
    // Begin to export video to the output path asynchronously.
    [session exportAsynchronouslyWithCompletionHandler:^(void) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (session.status) {
                case AVAssetExportSessionStatusUnknown: {
                    XYLog(@"AVAssetExportSessionStatusUnknown");
                }  break;
                case AVAssetExportSessionStatusWaiting: {
                    XYLog(@"AVAssetExportSessionStatusWaiting");
                }  break;
                case AVAssetExportSessionStatusExporting: {
                    XYLog(@"AVAssetExportSessionStatusExporting");
                }  break;
                case AVAssetExportSessionStatusCompleted: {
                    XYLog(@"AVAssetExportSessionStatusCompleted");
                    if (success) {
                        NSMutableDictionary * responseDic = [[NSMutableDictionary alloc] init];
                        
                        CMTime time = [videoAsset duration];
                        int seconds = ceil(time.value/time.timescale);
                        [responseDic setObject:@(seconds) forKey:@"videoTime"];
                        
                        CGFloat videoSize = [ImagePickerUtils getFileSize:outputPath];
                        [responseDic setObject:@(videoSize) forKey:@"videoSize"];
                        [responseDic setObject:outputPath forKey:@"videoPath"];
                        [responseDic setObject:[outputPath pathExtension] forKey:@"extension"];
                        [responseDic setObject:@(YES) forKey:@"isVideo"];
                        [responseDic setObject:[outputPath lastPathComponent] forKey:@"fileName"];
                        
                        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset: videoAsset];
                        imageGenerator.maximumSize = CGSizeMake(200, 0);//按比例生成， 不指定会默认视频原来的格式大小
                        CMTime actualTime; // 获取到视频帧图片的确切时间
                        CMTime firstTime = CMTimeMake(1, 1); // 第一帧
                        NSError *error = nil;
                        CGImageRef CGImage = [imageGenerator copyCGImageAtTime:firstTime actualTime:&actualTime error:&error];
                        if(!error) {
                            UIImage *image = [UIImage imageWithCGImage:CGImage];
                            NSData *thumbailData =  UIImageJPEGRepresentation(image, 0.5);
                            [responseDic setObject:[thumbailData base64EncodedStringWithOptions:0]  forKey:@"thunmbail"];
                        }
                        success(responseDic);
                    }
                }  break;
                case AVAssetExportSessionStatusFailed: {
                    XYLog(@"AVAssetExportSessionStatusFailed");
                    if (failure) {
                        failure(@"视频导出失败", session.error);
                    }
                }  break;
                case AVAssetExportSessionStatusCancelled: {
                    XYLog(@"AVAssetExportSessionStatusCancelled");
                    if (failure) {
                        failure(@"导出任务已被取消", nil);
                    }
                }  break;
                default: break;
            }
        });
    }];
}

+ (NSDictionary *)exportImageInfoWithImage:(UIImage *)image URL:(NSURL *)url {
    NSMutableDictionary * imageInfo = [[NSMutableDictionary alloc] init];
    //    NSData * imgData = [[NSData alloc] initWithContentsOfURL:url];
    //    UIImage * curImage = [UIImage imageWithData:imgData];
    NSData * imgData = UIImageJPEGRepresentation(image, 0.5);
    
    [imageInfo setObject:@(image.size.width) forKey:@"width"];
    [imageInfo setObject:@(image.size.height) forKey:@"height"];
    
    NSString * dataString = [imgData base64EncodedStringWithOptions:0]; // base64 encoded image string
    if(dataString) [imageInfo setObject:dataString forKey:@"data"];
    NSNumber * fileSizeValue = [NSNumber numberWithInt:0];
    NSError * fileSizeError = nil;
    NSString * imagePath = @"";
    if(url){
        imagePath = [url path];
        [url getResourceValue:&fileSizeValue forKey:NSURLFileSizeKey error:&fileSizeError];
    }
    [imageInfo setObject:imagePath forKey:@"uri"];
    [imageInfo setObject:fileSizeValue forKey:@"fileSize"];
    return imageInfo;
}

+ (void)exportVideo:(PHAsset *)pickedAsset success:(void(^)(NSDictionary *dict))success fail:(void (^)(NSString *errorMessage, NSError *error))failure {
    NSMutableDictionary * responseDic = [[NSMutableDictionary alloc] init];
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHImageRequestOptionsVersionCurrent;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    options.networkAccessAllowed = true;
    [[PHImageManager defaultManager] requestAVAssetForVideo:pickedAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        if ([asset isKindOfClass:[AVURLAsset class]]) {
            AVURLAsset* urlAsset = (AVURLAsset*)asset;
            [ImagePickerUtils exportVideoWithAsset:urlAsset success:^(NSDictionary * _Nonnull resultDic) {
                success(resultDic);
            } failure:^(NSString * _Nonnull errorMessage, NSError * _Nonnull error) {
                failure(errorMessage, error);
            }];
        } else {
            failure(@"资源类型异常？", nil);
        }
    }];
}

+ (void)exportImageWithAsset:(PHAsset *)asset success:(void(^)(NSDictionary *dict))success fail:(void (^)(NSString * errorMessage))fail {
    // 加载图片数据
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        NSURL * url = [info objectForKey:@"PHImageFileURLKey"];
        UIImage * aaImage = [UIImage imageWithData:imageData];
        NSDictionary * resDic = [ImagePickerUtils exportImageInfoWithImage:aaImage URL:url];
        success(resDic);
    }];
}

+ (void)saveImageToAlbum:(UIImage *)image success:(void (^)(NSURL * url))saveSuccess fail:(void (^)(NSString * errMsg))fail {
    NSMutableArray *imageIds = [NSMutableArray array];
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        //写入图片到相册
        PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        //记录本地标识，等待完成后取到相册中的图片对象
        [imageIds addObject:req.placeholderForCreatedAsset.localIdentifier];
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            //成功后取相册中的图片对象
            __block PHAsset *imageAsset = nil;
            PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:imageIds options:nil];
            [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                imageAsset = obj;
                *stop = YES;
                //_directory @"DCIM/100APPLE"
            }];
            if (imageAsset) {
                //加载图片数据
                [[PHImageManager defaultManager] requestImageDataForAsset:imageAsset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    NSURL * imgUrl = [info objectForKey:@"PHImageFileURLKey"];
                    if (imgUrl) {
                        saveSuccess(imgUrl);
                    } else {
                        fail(@"获取图片 url 失败");
                    }
                }];
            } else {
                fail(@"图片保存失败");
            }
        } else {
            fail(@"图片保存失败");
        }
    }];
}

- (void)getImageUrlWith:(PHFetchResult<PHAsset *> *)assets {
    [assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        *stop = YES;
        //_directory @"DCIM/100APPLE"
        [[PHImageManager defaultManager] requestImageDataForAsset:obj options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            NSURL * imgUrl = [info objectForKey:@"PHImageFileURLKey"];
            
        }];
    }];
}
/**
 * UIImagePickerControllerReferenceURL 获取 URL 后可使用此方法获取图片信息
 */
+ (void)getImageAssetFromImageAssetUrl:(NSURL *)imageAssetUrl {
    if (@available(iOS 11.0, *)) {
        PHFetchResult*result = [PHAsset fetchAssetsWithALAssetURLs:@[imageAssetUrl] options:nil];
        PHAsset *asset = [result firstObject];
        PHImageRequestOptions *phImageRequestOptions = [[PHImageRequestOptions alloc] init];
        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:phImageRequestOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            
        }];
    } else {
        ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
        [assetLibrary assetForURL:imageAssetUrl resultBlock:^(ALAsset *asset)  {
            
        } failureBlock:^(NSError *error) {
            // 失败的处理
        }];
    }
}

+ (CGFloat)getFileSize:(NSString *)path {
    NSLog(@"%@",path);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    float filesize = 0.0;
    if ([fileManager fileExistsAtPath:path]) {
        NSDictionary *fileDic = [fileManager attributesOfItemAtPath:path error:nil];//获取文件的属性
        unsigned long long size = [[fileDic objectForKey:NSFileSize] longLongValue];
        filesize = 1.0*size;
    } else {
        NSLog(@"找不到文件");
    }
    return filesize;
}

//此方法可以获取视频文件的时长。
+ (CGFloat)getVideoLength:(NSURL *)URL {
    AVURLAsset *avUrl = [AVURLAsset assetWithURL:URL];
    CMTime time = [avUrl duration];
    int second = ceil(time.value/time.timescale);
    return second;
}

@end
