//
//  XYLoggerFormatter.m
//  XYTest
//
//  Created by 张时疫 on 2018/2/27.
//  Copyright © 2018年 张时疫. All rights reserved.
//

#import "XYLoggerFormatter.h"

@interface XYLoggerFormatter ()

@property (nonatomic , strong) NSDateFormatter * dateFormatter;

@end

@implementation XYLoggerFormatter

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss:SSS"];
    }
    return self;
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    NSString *logLevel;
    switch (logMessage.flag) {
        case DDLogFlagError :
            	logLevel = @"Error";
            break;
        case DDLogFlagWarning :
            	logLevel = @"Warn";
            break;
        case DDLogFlagInfo :
            	logLevel = @"Info";
            break;
        case DDLogFlagDebug :
            	logLevel = @"Debug";
            break;
        default :
            	logLevel = @"Verbose";
            break;
    }
    NSString *dateAndTime = [self.dateFormatter stringFromDate:logMessage.timestamp];
    return [NSString stringWithFormat:@"[ %@ %@ ] \n %@", dateAndTime , logLevel , logMessage.message];
}

- (void)didAddToLogger:(id <DDLogger>)logger {
    
}
- (void)didAddToLogger:(id <DDLogger>)logger inQueue:(dispatch_queue_t)queue {
    
}
- (void)willRemoveFromLogger:(id <DDLogger>)logger {
    
}

@end

