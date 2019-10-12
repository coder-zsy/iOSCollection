//
//  NSObject+MethodSwizzling.m
//  XYTest
//
//  Created by 张时疫 on 2019/7/9.
//  Copyright © 2019 张时疫. All rights reserved.
//

#import "NSObject+MethodSwizzling.h"

@implementation NSObject (MethodSwizzling)
#pragma mark - public Method
+ (void)lbp_swizzleMethod:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector {
    class_swizzleInstanceMethod(self, originalSelector, swizzledSelector);
}

+ (void)lbp_swizzleClassMethod:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector {
    //类方法实际上是储存在类对象的类(即元类)中，即类方法相当于元类的实例方法,所以只需要把元类传入，其他逻辑和交互实例方法一样。
    Class class2 = object_getClass(self);
    class_swizzleInstanceMethod(class2, originalSelector, swizzledSelector);
}

#pragma mark - private method
void class_swizzleInstanceMethod(Class class, SEL originalSEL, SEL replacementSEL) {
    /*
    Class class = [self class];
    //原有方法
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    //替换原有方法的新方法
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    //先尝试給源SEL添加IMP，这里是为了避免源SEL没有实现IMP的情况
    BOOL didAddMethod = class_addMethod(class,originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) { // 添加成功：表明源SEL没有实现IMP，将源SEL的IMP替换到交换SEL的IMP
        class_replaceMethod(class,swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else { // 添加失败：表明源SEL已经有IMP，直接将两个SEL的IMP交换即可
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    */
    
    Method originMethod = class_getInstanceMethod(class, originalSEL);
    Method replaceMethod = class_getInstanceMethod(class, replacementSEL);
    if(class_addMethod(class, originalSEL, method_getImplementation(replaceMethod), method_getTypeEncoding(replaceMethod))) {
        class_replaceMethod(class, replacementSEL, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
    } else {
        method_exchangeImplementations(originMethod, replaceMethod);
    }
}
@end
