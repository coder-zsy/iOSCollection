//
//  XYImagePickerController.h
//  XYTest
//
//  Created by 张时疫 on 2019/4/22.
//  Copyright © 2019 张时疫. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, XYCameraType) {
    XYCameraTypeLibrary = 0, // 相册
    XYCameraTypeShooting = 1, // 拍照
    XYCameraTypeVideo = 2 // 摄像
};

typedef void(^ImagePickerResult)(UIImage* image, NSURL* imageURL, NSError* error);

@interface XYImagePickerController : UIViewController

@end

NS_ASSUME_NONNULL_END
