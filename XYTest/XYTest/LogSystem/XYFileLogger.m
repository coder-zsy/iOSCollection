//
//  XYLogger.m
//  XYTest
//
//  Created by 张时疫 on 2018/2/27.
//  Copyright © 2018年 张时疫. All rights reserved.
//

#import "XYFileLogger.h"

@implementation XYFileLogger


- (void)logMessage:(DDLogMessage *)logMessage {
    [super logMessage:logMessage];
}
- (void)willLogMessage {
    [super willLogMessage];
}

- (void)didLogMessage {
    [super didLogMessage];
}

@end
