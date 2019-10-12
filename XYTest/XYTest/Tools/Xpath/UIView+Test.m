//
//  UIView+Test.m
//  XYTest
//
//  Created by 张时疫 on 2019/7/9.
//  Copyright © 2019 张时疫. All rights reserved.
//

#import "UIView+Test.h"
#import "NSObject+MethodSwizzling.h"
@implementation UIView (Test)

// UIView 分类
- (NSString *)obtainSameSuperViewSameClassViewTreeIndexPat {
    NSString *classStr = NSStringFromClass([self class]);
    //cell的子view
    //UITableView 特殊的superview (UITableViewContentView)
    //UICollectionViewCell
    BOOL shouldUseSuperView =
    ([classStr isEqualToString:@"UITableViewCellContentView"]) ||
    ([[self.superview class] isKindOfClass:[UITableViewCell class]])||
    ([[self.superview class] isKindOfClass:[UICollectionViewCell class]]);
    if (shouldUseSuperView) {
        return [self obtainIndexPathByView:self.superview];
    } else {
        return [self obtainIndexPathByView:self];
    }
}

- (NSString *)obtainIndexPathByView:(UIView *)view {
    NSInteger viewTreeNodeDepth = NSIntegerMin;
    NSInteger sameViewTreeNodeDepth = NSIntegerMin;
    
    NSString *classStr = NSStringFromClass([view class]);
    
    NSMutableArray *sameClassArr = [[NSMutableArray alloc]init];
    //所处父view的全部subviews根节点深度
    for (NSInteger index =0; index < view.superview.subviews.count; index ++) {
        //同类型
        if  ([classStr isEqualToString:NSStringFromClass([view.superview.subviews[index] class])]){
            [sameClassArr addObject:view.superview.subviews[index]];
        }
        if (view == view.superview.subviews[index]) {
            viewTreeNodeDepth = index;
            break;
        }
    }
    //所处父view的同类型subviews根节点深度
    for (NSInteger index =0; index < sameClassArr.count; index ++) {
        if (view == sameClassArr[index]) {
            sameViewTreeNodeDepth = index;
            break;
        }
    }
    return [NSString stringWithFormat:@"%ld",sameViewTreeNodeDepth];
    
}



@end
