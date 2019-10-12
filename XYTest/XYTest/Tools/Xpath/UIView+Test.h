//
//  UIView+Test.h
//  XYTest
//
//  Created by 张时疫 on 2019/7/9.
//  Copyright © 2019 张时疫. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Test)


- (NSString *)obtainSameSuperViewSameClassViewTreeIndexPat;
- (NSString *)obtainIndexPathByView:(UIView *)view;
@end

NS_ASSUME_NONNULL_END
