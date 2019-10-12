//
//  UIViewController+lbpka.m
//  XYTest
//
//  Created by 张时疫 on 2019/7/9.
//  Copyright © 2019 张时疫. All rights reserved.
//

#import "UIViewController+lbpka.h"
#import "NSObject+MethodSwizzling.h"

static char *lbp_viewController_open_time = "lbp_viewController_open_time";
static char *lbp_viewController_close_time = "lbp_viewController_close_time";

@implementation UIViewController (lbpka)

// load 方法里面添加 dispatch_once 是为了防止手动调用 load 方法。
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            [[self class] lbp_swizzleMethod:@selector(viewWillAppear:) swizzledSelector:@selector(lbp_viewWillAppear:)];
            [[self class] lbp_swizzleMethod:@selector(viewWillDisappear:) swizzledSelector:@selector(lbp_viewWillDisappear:)];
        }
    });
}

#pragma mark - add prop
- (void)setOpenTime:(NSDate *)openTime {
    objc_setAssociatedObject(self,&lbp_viewController_open_time, openTime, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDate *)getOpenTime {
    return objc_getAssociatedObject(self, &lbp_viewController_open_time);
}

- (void)setCloseTime:(NSDate *)closeTime {
    objc_setAssociatedObject(self,&lbp_viewController_close_time, closeTime, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDate *)getCloseTime {
    return objc_getAssociatedObject(self, &lbp_viewController_close_time);
}

- (void)lbp_viewWillAppear:(BOOL)animated {
    NSString *className = NSStringFromClass([self class]);
    NSString *refer = [NSString string];
    //TODO:TODO 是否只埋本地有url的page
//    if ([self getPageUrl:className]) {
        //设置打开时间
        [self setOpenTime:[NSDate dateWithTimeIntervalSinceNow:0]];
        if (self.navigationController) {
            if (self.navigationController.viewControllers.count >=2) {
                //获取当前vc 栈中 上一个VC
                UIViewController *referVC =  self.navigationController.viewControllers[self.navigationController.viewControllers.count-2];
//                refer = [self getPageUrl:NSStringFromClass([referVC class])];
            }
        }
        if (!refer || refer.length == 0) {
            refer = @"unknown";
        }
//        [UserTrackDataCenter openPage:[self getPageUrl:className] fromPage:refer];
//    }
    [self lbp_viewWillAppear:animated];
}

- (void)lbp_viewWillDisappear:(BOOL)animated {
    NSString *className = NSStringFromClass([self class]);
//    if ([self getPageUrl:className]) {
        [self setCloseTime:[NSDate dateWithTimeIntervalSinceNow:0]];
//        [UserTrackDataCenter leavePage:[self getPageUrl:className] spendTime:[self p_calculationTimeSpend]];
//    }
    [self lbp_viewWillDisappear:animated];
}

#pragma mark - private method
- (NSString *)p_calculationTimeSpend {
    if (![self getOpenTime] || ![self getCloseTime]) {
        return @"unknown";
    }
    NSTimeInterval aTimer = [[self getCloseTime] timeIntervalSinceDate:[self getOpenTime]];
    int hour = (int)(aTimer/3600);
    int minute = (int)(aTimer - hour*3600)/60;
    int second = aTimer - hour*3600 - minute*60;
    return [NSString stringWithFormat:@"%d",second];
}

@end
