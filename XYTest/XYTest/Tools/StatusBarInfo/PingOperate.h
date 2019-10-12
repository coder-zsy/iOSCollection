//
//  PingOperate.h
//  XYTest
//
//  Created by 张时疫 on 2019/7/22.
//  Copyright © 2019 张时疫. All rights reserved.
//

// http://hedy.ltd/2018/11/02/2018-11-01/

#import <Foundation/Foundation.h>

@class PingOperate;
NS_ASSUME_NONNULL_BEGIN
@protocol PingOperateDelegate <NSObject>

@required
- (void)pingCompliteWithOperate:(PingOperate *)operate avaTime:(float)avaTime lossRate:(NSString *)rate error:(nullable NSError *)error;

@end


@interface PingOperate : NSObject

@property (nonatomic, weak) id<PingOperateDelegate>delegate;
@property (nonatomic, assign) BOOL pingActioned;   //是否在Ping中
@property (nonatomic, assign) NSInteger numOfPing; //需要发送ping地址的次数
@property (nonatomic, assign) NSTimeInterval timeIntervalOfPing; //ping的时间间隔

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithHostName:(NSString *)hostname NS_DESIGNATED_INITIALIZER;
- (void)startPing;
- (void)stopPing;
- (NSString *)getIPAdd;


@end

NS_ASSUME_NONNULL_END
