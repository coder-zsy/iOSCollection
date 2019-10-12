//
//  BaseViewController.m
//  jiedanyi3
//
//  Created by 张时疫 on 2018/4/19.
//  Copyright © 2018年 Facebook. All rights reserved.
//
typedef NS_ENUM(NSInteger, XYStatusBarType) {
  XYStatusBarTypeBlack = 0,
  XYStatusBarTypeLight,
  XYStatusBarTypeHide,
};

#import "BaseViewController.h"

@interface BaseViewController ()

@property (nonatomic, assign) XYStatusBarType statusBarType;

@end

@implementation BaseViewController

#pragma mark --- Life Circle

- (instancetype)init {
  if (self = [super init]) {
    // 监听通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeStatusBar:) name:@"XYChangeStatusBarNotification" object:nil];
      self.statusBarType = XYStatusBarTypeHide;
  }
  return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGB(255, 255, 255);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

- (BOOL)prefersStatusBarHidden {
    // return YES;
    if (self.statusBarType == XYStatusBarTypeHide) {
        return YES;
    } else {
        return NO;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    // return UIStatusBarStyleLightContent;
    if (self.statusBarType == XYStatusBarTypeLight) {
        return UIStatusBarStyleLightContent;
    } else if (self.statusBarType == XYStatusBarTypeBlack) {
        return UIStatusBarStyleDefault;
    } else {
        return UIStatusBarStyleDefault;
    }
}

- (void)changeStatusBar:(NSNotification *)notification {
  NSString * type = notification.userInfo[@"type"];
  if ([type isEqualToString:@"hide"]) {
    self.statusBarType = XYStatusBarTypeHide;
  } else if ([type isEqualToString:@"light"]) {
    self.statusBarType = XYStatusBarTypeLight;
  } else {
    self.statusBarType = XYStatusBarTypeBlack;
  }
  [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark --- Setter ---
#pragma mark --- Getter ---

@end
