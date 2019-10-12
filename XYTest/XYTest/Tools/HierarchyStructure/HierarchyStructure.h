//
//  HierarchyStructure.h
//  XYTest
//
//  Created by 张时疫 on 2019/7/9.
//  Copyright © 2019 张时疫. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HierarchyStructure : NSObject
/**
 * 返回传入veiw及其上的所有子视图层级结构和基本信息
 * 类似  po [view recursiveDescription] 方法
 * [UIViewController _printHierarchy]
 * @param view 需要获取层级结构的view
 *
 * @return 字符串
 */
- (NSString *)getHierarchyStructureOfView:(UIView *)view;

- (void)dumpViews:(UIView*) view text:(NSString *)text indent:(NSString *)indent;
@end

NS_ASSUME_NONNULL_END
