//
//  XYLogFileManager.m
//  XYTest
//
//  Created by 张时疫 on 2018/2/27.
//  Copyright © 2018年 张时疫. All rights reserved.
//

#import "XYLogFileManager.h"
#import "XYLoggerFormatter.h"
#import "XYFileLogger.h"
@interface XYLogFileManager ()

@property (nonatomic, strong) UploadFileLogBlock uploadBlock;
@property (nonatomic, assign) XYLogFrequency uploadFrequency;
@property (nonatomic, assign) NSTimeInterval lastUploadTimeInterval;
@property (nonatomic, assign) BOOL LogFileEnabled;
@property (nonatomic, strong) XYFileLogger * fileLogger;
@property (nonatomic, assign) double logFreshTimer;

@end

@implementation XYLogFileManager

singleton_implementation(XYLogFileManager);
- (instancetype) init {
    self = [super init];
    if (self) {
        [DDLog addLogger:[DDASLLogger sharedInstance]]; //add log to Apple System Logs
        [DDLog addLogger:[DDTTYLogger sharedInstance]]; //add log to Xcode console
        
        [DDTTYLogger sharedInstance].logFormatter = [[XYLoggerFormatter alloc] init];
    }
    self.lastUploadTimeInterval = [[NSUserDefaults standardUserDefaults] doubleForKey:@"LastUploadTimeInterval"] ? [[NSUserDefaults standardUserDefaults] doubleForKey:@"LastUploadTimeInterval"] : 0;
    return self;
}

/**
 开启日志文件系统
 */
- (void)enableFileLogSystem {
    
    _LogFileEnabled = YES;
    
    _fileLogger = [[XYFileLogger alloc] init];
    
    _fileLogger.rollingFrequency = 60 * 60 * 24*30; // 有效期是24小时
    _fileLogger.logFileManager.maximumNumberOfLogFiles = 30;  //最多文件数量为2个
    _fileLogger.logFormatter = [[XYLoggerFormatter alloc] init];  //日志消息格式化
    _fileLogger.maximumFileSize = 1024*50;   //每个文件数量最大尺寸为50k
    _fileLogger.logFileManager.logFilesDiskQuota = 200*1024;     //所有文件的尺寸最大为200k
    
    [DDLog addLogger:_fileLogger];
}

/**
 开启自定义文件系统
 
 @param direct 日志文件夹
 @param freshFrequency 日志刷新时间
 */
- (void)enableFileLogSystemWithDirectory:(NSString *)direct freshTimeInterval:(XYLogFrequency)freshFrequency; {
    
    _LogFileEnabled = YES;
    
    DDLogFileManagerDefault *logFileManager = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:direct];
    
    _fileLogger = [[XYFileLogger alloc] initWithLogFileManager:logFileManager];
    
    
    switch (freshFrequency) {
        case XYLogFrequencyYear:
            
            _logFreshTimer = 60 * 60 * 24 * 365;
            break;
            
        case XYLogFrequencyMonth:
            
            _logFreshTimer = 60 * 60 * 24 * 30;
            break;
            
        case XYLogFrequencyWeek:
            
            _logFreshTimer = 60 * 60 * 24 * 7;
            break;
            
        case XYLogFrequencyDay:
            
            _logFreshTimer = 60 * 60 * 24;
            break;
            
        default:
            
            _logFreshTimer = 60 * 60 * 24 * 30;
            break;
    }
    
    
    _fileLogger.rollingFrequency = _logFreshTimer;
    //_fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    
    [DDLog addLogger:_fileLogger];
}

/**
 获取当前的日志文件文件夹
 
 @return 日志文件夹地址
 */
- (NSString *)getCurrentLogFilePath {
    
    if (_LogFileEnabled && _fileLogger) {
        
        return _fileLogger.currentLogFileInfo.filePath;
    } else {
        
        return @"";
    }
}

/**
 删除日志文件,
 注意调用删除日志文件的方法后, 要在下次启动才会产生新的日志文件
 
 @return 删除的结果
 */
- (BOOL)clearFileLog {
    
    if ([self getCurrentLogFilePath].length > 1) {
        
        NSError *error;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        [fileManager removeItemAtPath:[self getCurrentLogFilePath] error:&error];
        
        if (!error) {
            
            return true;
        } else {
            
            return false;
        }
    }
    
    return true;
}

/**
 停止所有Log系统
 */
- (void)stopLog {
    
    [self clearFileLog];
    _LogFileEnabled = NO;
    
    [DDLog removeAllLoggers];
    
}

/**
 上传Log文件
 
 @param uploadBlock 上传的Block
 */
- (void)uploadFileLogWithBlock:(UploadFileLogBlock)uploadBlock {
    
    if ([self getCurrentLogFilePath].length > 1 && _LogFileEnabled) {
        
        uploadBlock([self getCurrentLogFilePath]);
    }
}

/**
 设置定期上传文件, 不会立即发送
 
 @param uploadBlock 上传文件的block
 @param uploadFrequency 上传频率
 */
- (void)uploadFileLogWithBlock:(UploadFileLogBlock)uploadBlock
                 withFrequency:(XYLogFrequency)uploadFrequency {
    
    self.uploadBlock     = uploadBlock;
    self.uploadFrequency = uploadFrequency;
    
    if (_LogFileEnabled) {
        
        if (!self.lastUploadTimeInterval) {
            
            //获取当前的时间戳
            self.lastUploadTimeInterval = [[NSDate date] timeIntervalSince1970];
            
            //存储时间戳
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setDouble:self.lastUploadTimeInterval forKey:@"LastUploadTimeInterval"];
        }
        
        NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970];
        
        NSInteger days;
        switch (uploadFrequency) {
            case XYLogFrequencyYear:
                days = 365;
                break;
                
            case XYLogFrequencyMonth:
                days = 30;
                break;
                
            case XYLogFrequencyWeek:
                days = 7;
                break;
                
            case XYLogFrequencyDay:
                days = 1;
                break;
                
            default:
                break;
        }
        
        if (currentTimeInterval - self.lastUploadTimeInterval > 60 * 60 * 24 * days) {
            
            [self uploadFileLogWithBlock:uploadBlock];
        }
    }
}

/**
 log 错误信息
 
 @param message 错误信息
 */
- (void)logEror:(NSString *)message {
    
    DDLogError(@"%@", message);
}

/**
 Log 警告信息
 
 @param message 警告信息
 */
- (void)logWarn:(NSString *)message {
    
    DDLogWarn(@"%@", message);
}

/**
 log 普通信息
 
 @param message 普通信息
 */
- (void)logInfo:(NSString *)message {
    
    DDLogInfo(@"%@", message);
}

/**
 log 调试信息
 
 @param message 调试信息
 */
- (void)logDebug:(NSString *)message {
    
    DDLogDebug(@"%@", message);
}

@end

