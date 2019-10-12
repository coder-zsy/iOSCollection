//
//  UIResponder+Test.m
//  XYTest
//
//  Created by 张时疫 on 2019/7/9.
//  Copyright © 2019 张时疫. All rights reserved.
//

#import "UIResponder+Test.h"
#import "NSObject+MethodSwizzling.h"
#import "UIView+Test.h"

@implementation UIResponder (Test)

//UIResponder分类
//- (NSString *)lbp_identifierKa {
//    //    if (self.xq_identifier_ka == nil) {
//    if ([self isKindOfClass:[UIView class]]) {
//        UIView *view = (id)self;
//        NSString *sameViewTreeNode = [view obtainSameSuperViewSameClassViewTreeIndexPath];
//        NSMutableString *str = [NSMutableString string];
//        //特殊的 加减购 因为带有spm但是要区分加减 需要带TreeNode
//        NSString *className = [NSString stringWithUTF8String:object_getClassName(view)];
//        if (!view.accessibilityIdentifier || [className isEqualToString:@"lbpButton"]) {
//            [str appendString:sameViewTreeNode];
//            [str appendString:@","];
//        }
//        while (view.nextResponder) {
//            [str appendFormat:@"%@,", NSStringFromClass(view.class)];
//            if ([view.class isSubclassOfClass:[UIViewController class]]) {
//                break;
//            }
//            view = (id)view.nextResponder;
//        }
//        self.xq_identifier_ka = [self md5String:[NSString stringWithFormat:@"%@",str]];
//        //            self.xq_identifier_ka = [NSString stringWithFormat:@"%@",str];
//    }
//    //    }
//    return self.xq_identifier_ka;
//}

//UIResponder Category 生成 viewPath
//- (NSString *)lbp_identifierKa2 {
//    //    if (self.xq_identifier_ka == nil) {
//    if ([self isKindOfClass:[UIView class]]) {
//        UIView *view = (id)self;
//        NSString *sameViewTreeNode = [view obtainSameSuperViewSameClassViewTreeIndexPath];
//        NSMutableString *str = [NSMutableString string];
//        //特殊的 加减购 因为带有spm但是要区分加减 需要带TreeNode
//        NSString *className = [NSString stringWithUTF8String:object_getClassName(view)];
//        if (!view.accessibilityIdentifier || [className isEqualToString:@"lbpButton"]) {
//            [str appendString:sameViewTreeNode];
//            [str appendString:@","];
//        }
//        while (view.nextResponder) {
//            if ([view respondsToSelector:@selector(setUniqueIdentifier)]) {
//                NSString *unqiueIdentifier = [view setUniqueIdentifier];
//                if (unqiueIdentifier) {
//                    [str appendFormat:@"%@,", unqiueIdentifier];
//                }
//            }
//            [str appendFormat:@"%@,", NSStringFromClass(view.class)];
//            if ([view.class isSubclassOfClass:[UIViewController class]]) {
//                break;
//            }
//            view = (id)view.nextResponder;
//        }
//        self.xq_identifier_ka = [self md5String:[NSString stringWithFormat:@"%@",str]];
//        //            self.xq_identifier_ka = [NSString stringWithFormat:@"%@",str];
//    }
//    //    }
//    return self.xq_identifier_ka;
//}


@end
