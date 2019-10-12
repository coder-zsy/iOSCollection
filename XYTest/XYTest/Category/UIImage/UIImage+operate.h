//
//  UIImage+operate.h
//  jiedanyi3
//
//  Created by 张时疫 on 2017/9/7.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (operate)


+ (UIImage *)fixOrientation:(UIImage *)srcImg;

+ (UIImage*)downscaleImageIfNecessary:(UIImage*)image maxWidth:(float)maxWidth maxHeight:(float)maxHeight;

@end
