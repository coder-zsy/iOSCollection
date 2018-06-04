//
//  AGTimer.m
//  AGTimer
//
//  Created by zsy on 16/3/2.
//  Copyright © 2016年 zsy. All rights reserved.
//

#import "AGTimer.h"


@interface AGTimer ()




@property (nonatomic , assign) BOOL isValid;
@property (nonatomic , assign) BOOL isRepeating;

@end

@implementation AGTimer

- (instancetype)init {
    self = [super init];
    self.isValid = YES;
    self.isRepeating = YES;    
    return self;
}

+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval target:(nullable id)target selector:(nullable SEL)selector userInfo:(nullable id)userInfo repeats:(BOOL)repeats {
    AGTimer *timer = [[AGTimer alloc] init];
    timer.interval = interval;
    timer.target = target;
    timer.selector = selector;
    timer.userInfo = userInfo;
    
    if (repeats) {
        [timer repeatSelector];
    } else {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [target performSelectorOnMainThread:selector withObject:userInfo waitUntilDone:NO];
        });
    }
    return timer;
}

- (void)repeatSelector {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.interval * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        if (self.isRepeating) {
            [self.target performSelectorOnMainThread:self.selector withObject:self.userInfo waitUntilDone:NO];
        }
        if (self.isValid) {
            [self repeatSelector];
        }
    });
}

- (void)reStart {
    self.isRepeating = YES;
}

- (void)stop {
    self.isRepeating = NO;
}

- (void)invalidate {
    self.isValid = NO;
}
@end
