//
//  HierarchyStructure.m
//  XYTest
//
//  Created by 张时疫 on 2019/7/9.
//  Copyright © 2019 张时疫. All rights reserved.
//

#import "HierarchyStructure.h"

@implementation HierarchyStructure

/**
 * 返回传入veiw的所有层级结构
 *
 * @param view 需要获取层级结构的view
 *
 * @return 字符串
 */
- (NSString *)getHierarchyStructureOfView:(UIView *)view {
    if ([view isKindOfClass:[UITableViewCell class]]) return @"";
    // 1.初始化
    NSMutableString *xml = [NSMutableString string];
    
    // 2.标签开头
    [xml appendFormat:@"<%@ frame=\"%@\"", view.class, NSStringFromCGRect(view.frame)];
    if (!CGPointEqualToPoint(view.bounds.origin, CGPointZero)) {
        [xml appendFormat:@" bounds=\"%@\"", NSStringFromCGRect(view.bounds)];
    }
    
    if ([view isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scroll = (UIScrollView *)view;
        if (!UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, scroll.contentInset)) {
            [xml appendFormat:@" contentInset=\"%@\"", NSStringFromUIEdgeInsets(scroll.contentInset)];
        }
    }
    
    // 3.判断是否要结束
    if (view.subviews.count == 0) {
        [xml appendString:@" />"];
        return xml;
    } else {
        [xml appendString:@">"];
    }
    
    // 4.遍历所有的子控件
    for (UIView *child in view.subviews) {
        NSString *childXml = [self getHierarchyStructureOfView:child];
        [xml appendString:childXml];
    }
    
    // 5.标签结尾
    [xml appendFormat:@"</%@>", view.class];
    
    return xml;
}

- (void)dumpViews:(UIView*) view text:(NSString *)text indent:(NSString *)indent {
    Class cl = [view class];
    NSString *classDescription = [cl description];
    while ([cl superclass]) {
        cl = [cl superclass];
        classDescription = [classDescription stringByAppendingFormat:@":%@", [cl description]];
     }
    
    if ([text compare:@""] == NSOrderedSame) {
        NSLog(@"%@ %@", classDescription, NSStringFromCGRect(view.frame));
    } else {
        NSLog(@"%@ %@ %@", text, classDescription, NSStringFromCGRect(view.frame));
    }
    for (NSUInteger i = 0; i < [view.subviews count]; i++) {
        UIView *subView = [view.subviews objectAtIndex:i];
        NSString *newIndent = [[NSString alloc] initWithFormat:@"  %@", indent];
        NSString *msg = [[NSString alloc] initWithFormat:@"%@%d:", newIndent, i];
        [self dumpViews:subView text:msg indent:newIndent];
     }
}


@end
