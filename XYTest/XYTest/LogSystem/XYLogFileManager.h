//
//  XYLogFileManager.h
//  XYTest
//
//  Created by 张时疫 on 2018/2/27.
//  Copyright © 2018年 张时疫. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>
#import "Singleton.h"

/**关闭日志：DDLogLevelOff*/
static const DDLogLevel ddLogLevel = DDLogLevelDebug;

#define XYLogError(...) DDLogError(@"%s 第%d行 %@\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])

#define XYlogWarn(...) DDLogWarn(@"%s 第%d行 %@\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])

#define XYLogInfo(...) DDLogInfo(@"%s 第%d行 %@\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])

#define XYLogDebug(...) DDLogDebug(@"%s 第%d行 %@\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])

#define XYLogVerbose(...) DDLogVerbose(@"%s 第%d行 %@\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])

typedef void(^UploadFileLogBlock)(NSString *logFilePath);
typedef enum : NSUInteger {
    XYLogFrequencyYear = 0,
    XYLogFrequencyMonth,
    XYLogFrequencyWeek,
    XYLogFrequencyDay,
} XYLogFrequency;

@interface XYLogFileManager : DDLogFileManagerDefault




/**
 获取单例
 
 @return 单例
 */
singleton_interface(XYLogFileManager);

/**
 开启日志文件系统, 默认日志文件保存1个月
 */
- (void)enableFileLogSystem;

/**
 开启自定义日志文件系统
 
 @param direct 日志文件文件夹地址
 @param freshFrequency 日志刷新频率
 */
- (void)enableFileLogSystemWithDirectory:(NSString *)direct freshTimeInterval:(XYLogFrequency)freshFrequency;

/**
 获取当前的日志文地址
 注意日志文件名称含有空格
 
 @return 日志文件地址
 */
- (NSString *)getCurrentLogFilePath;

/**
 删除日志文件,
 注意调用删除日志文件的方法后, 要在下次启动才会产生新的日志文件
 
 @return 删除的结果
 */
- (BOOL)clearFileLog;

/**
 停止所有Log系统, 并清除日志文件
 */
- (void)stopLog;

/**
 上传Log文件, 注意日志文件名称含有空格
 
 @param uploadBlock 上传的Block
 */
- (void)uploadFileLogWithBlock:(UploadFileLogBlock)uploadBlock;

/**
 设置定期上传文件, 不会立即发送 注意日志文件名称含有空格
 
 @param uploadBlock 上传文件的block
 @param uploadFrequency 上传频率
 */
- (void)uploadFileLogWithBlock:(UploadFileLogBlock)uploadBlock
                 withFrequency:(XYLogFrequency)uploadFrequency;

/**
 log 错误信息
 
 @param message 错误信息
 */
- (void)logEror:(NSString *)message;

/**
 Log 警告信息
 
 @param message 警告信息
 */
- (void)logWarn:(NSString *)message;

/**
 log 普通信息
 
 @param message 普通信息
 */
- (void)logInfo:(NSString *)message;

/**
 log 调试信息
 
 @param message 调试信息
 */
- (void)logDebug:(NSString *)message;

@end
