//
//  PingOperate.m
//  XYTest
//
//  Created by 张时疫 on 2019/7/22.
//  Copyright © 2019 张时疫. All rights reserved.
//

#import "PingOperate.h"
#import "SimplePing.h"
#import <arpa/inet.h>
#include <netdb.h>

@interface PingOperate()<SimplePingDelegate>

@property (nonatomic, strong) NSTimer *timer;    //不断发送ping命令的定时器
@property (nonatomic, strong) SimplePing *simplePing;
@property (nonatomic, strong) NSMutableArray *pingItems; //存储已经发送出去，但是没有收到结果的包
@property (nonatomic, strong) NSString *ipAdd; //IP地址
@property (nonatomic, assign) NSInteger timesOfPing; //已经发送了ping的次数
@property (nonatomic, assign) NSInteger succOfPingTimes; //成功收到回调的次数
@property (nonatomic, strong) NSMutableArray *succPingResults; //成功回调的ping包的时间集合
@property (nonatomic, strong) NSMutableDictionary *beginDateDic; //ping包发送时间集合

@end


@implementation PingOperate

- (instancetype)initWithHostName:(NSString *)hostname {
    self = [super init];
    if (self) {
        self.simplePing = [[SimplePing alloc] initWithHostName:hostname];
        self.simplePing.delegate = self;
        self.simplePing.addressStyle = SimplePingAddressStyleAny;
        self.pingItems = [[NSMutableArray alloc] init];
        self.ipAdd = [self getIPAddressForHost:self.simplePing.hostName];
        self.timesOfPing = 0;
        self.succOfPingTimes = 0;
        self.succPingResults = [[NSMutableArray alloc] init];
        self.beginDateDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - 开始ping
- (void)startPing {
    [self.simplePing start];
    self.pingActioned = YES;
}

#pragma mark - 结束ping
- (void)stopPing {
    [self.timer invalidate];
    self.timer = nil;
    [self.simplePing stop];
    self.pingActioned = NO;
}

#pragma mark - 获取IP地址
- (NSString *)getIPAdd {
    return self.ipAdd;
}

#pragma mark - 激活timer
- (void)actionTimer {
    if (self.timeIntervalOfPing) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeIntervalOfPing target:self selector:@selector(sendPingData) userInfo:nil repeats:YES];
    } else {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sendPingData) userInfo:nil repeats:YES];
    }
}

#pragma mark - 发送数据
- (void)sendPingData {
    if (self.timesOfPing < self.numOfPing) {
        [self.simplePing sendPingWithData:nil];
        self.timesOfPing ++;
    } else {
        //1秒之后执行
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.timer setFireDate:[NSDate distantFuture]];
            [self stopPing];
            if(self.delegate != nil && [self.delegate conformsToProtocol:@protocol(PingOperateDelegate)]) {
                float avaTime = [self getAvarageTimeOfSuccPing];
                float rate = (1.0 - ((self.succOfPingTimes * 100.0) / (self.numOfPing * 100.0))) * 100.0;
                [self.delegate pingCompliteWithOperate:self avaTime:avaTime lossRate:[NSString stringWithFormat:@"%.2lf",rate] error:nil];
            }
        });
    }
}

#pragma mark - <SimplePingDelegate>
/*
 * Ping开始
 */
- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address {
    [self actionTimer];
}

/*
 * Ping失败
 */
- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error {
    NSLog(@"ping 失败 --- %@",error);
    if(self.delegate != nil && [self.delegate conformsToProtocol:@protocol(PingOperateDelegate)]) {
        [self.delegate pingCompliteWithOperate:self avaTime:9999.0 lossRate:@"100%" error:error];
    }
}

/*
 * 成功发送一份ping数据
 */
- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber {
    NSString *sequenceNum = [NSString stringWithFormat:@"%d",sequenceNumber];
    [self.pingItems addObject:sequenceNum];
    [self.beginDateDic setObject:[NSDate date] forKey:sequenceNum];
    
    //在接收到数据之后，会把这一个包的标记移除，如果下一个周期来查询的时候，这个包还在数组里面，证明这个包超时
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if([self.pingItems containsObject:sequenceNum]) {
            NSLog(@"超时---->");
            [self.pingItems removeObject:sequenceNum];
        }
    });
}

/*
 * 发送Ping数据失败
 */
- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error {
    NSLog(@"发包失败--->%@", error.localizedDescription);
    if(self.delegate != nil && [self.delegate conformsToProtocol:@protocol(PingOperateDelegate)]) {
        [self.delegate pingCompliteWithOperate:self avaTime:9999.0 lossRate:@"100%" error:error];
    }
}

/*
 * 收到ping响应数据
 */
- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber {
    self.succOfPingTimes ++;
    NSString *sequenceNum = [NSString stringWithFormat:@"%d",sequenceNumber];
    NSDate *beginDate = (NSDate *)[self.beginDateDic objectForKey:sequenceNum];
    float delayTime = [[NSDate date] timeIntervalSinceDate:beginDate] * 1000;
    //在接收到数据之后，会把这一个包的标记移除
    [self.pingItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj isEqualToString:sequenceNum]) {
            [self.pingItems removeObject:obj];
        }
    }];
    [self.succPingResults addObject:[NSString stringWithFormat:@"%f",delayTime]];
}

/*
 * 收到未知响应数据
 */
- (void)simplePing:(SimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet {
    
}

#pragma mark - 从URL获取IP地址
- (NSString *)getIPAddressForHost: (NSString *) theHost {
    struct hostent *host = gethostbyname([theHost UTF8String]);
    if (!host) {herror("resolv"); return NULL; }
    struct in_addr **list = (struct in_addr **)host->h_addr_list;
    NSString *addressString = [NSString stringWithCString:inet_ntoa(*list[0]) encoding:NSUTF8StringEncoding];
    return addressString;
}

#pragma mark - 获取成功返回的ping包的平均延迟时间
- (float)getAvarageTimeOfSuccPing {
    if (self.succPingResults < 0) {
        return 0.00;
    }
    CGFloat avaTime = [[self.succPingResults valueForKeyPath:@"@avg.floatValue"] floatValue];
    return avaTime;
}

@end
