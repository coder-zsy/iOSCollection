//
//  AGTimer.h
//  AGTimer
//
//  Created by zsy on 16/3/2.
//  Copyright © 2016年 zsy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGTimer : NSObject

@property  NSTimeInterval interval;
@property (nullable,weak) id target;
@property (nullable,nonatomic, assign) SEL selector;
@property (nullable, retain) id userInfo;


+ (nullable instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval target:(nullable id)target selector:(nullable SEL)selector userInfo:(nullable id)userInfo repeats:(BOOL)repeats;



- (void)reStart;
- (void)stop;
- (void)invalidate;

@end
