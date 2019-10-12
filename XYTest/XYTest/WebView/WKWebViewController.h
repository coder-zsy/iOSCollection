//
//  WKWebViewController.h
//  XYTest
//
//  Created by 张时疫 on 2019/3/25.
//  Copyright © 2019 张时疫. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKWebViewController : UIViewController

@property (nonatomic , copy) NSString * urlString;
@property (nonatomic , strong) NSURL * url;


@end

NS_ASSUME_NONNULL_END
