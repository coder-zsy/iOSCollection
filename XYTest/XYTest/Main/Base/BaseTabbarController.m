//
//  BaseTabbarController.m
//  jiedanyi3
//
//  Created by 张时疫 on 2018/4/19.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "BaseTabbarController.h"
#import "BaseNavigationViewController.h"
#import "SettingViewController.h"
#import "HomeViewController.h"
#import "MineViewController.h"
#import "CenterViewController.h"


@interface BaseTabbarController ()

@end

@implementation BaseTabbarController

#pragma mark --- life circle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initSubviews];
}

#pragma mark - 控制屏幕旋转方法
- (BOOL)shouldAutorotate {
  return [self.selectedViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
  return [self.selectedViewController supportedInterfaceOrientations];
}

//Presentation推出支持的屏幕旋转
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
  return [self.selectedViewController preferredInterfaceOrientationForPresentation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initSubviews {
    HomeViewController * homeVC = [[HomeViewController alloc] init];
    homeVC.title = @"首页";
    homeVC.tabBarItem.image = [UIImage imageNamed:@"home_icon_normal"];
    homeVC.tabBarItem.selectedImage = [[UIImage imageNamed:@"home_icon_selected"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    BaseNavigationViewController * homeNav = [[BaseNavigationViewController alloc] initWithRootViewController:homeVC];
    
    CenterViewController * centerVC = [[CenterViewController alloc] init];
    centerVC.title = @"中心";
    centerVC.tabBarItem.image = [UIImage imageNamed:@"order_icon_normal"];
    centerVC.tabBarItem.selectedImage = [[UIImage imageNamed:@"order_icon_selected"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    BaseNavigationViewController * centerNav = [[BaseNavigationViewController alloc] initWithRootViewController:centerVC];
    
    MineViewController * mineVC = [[MineViewController alloc] init];
    mineVC.title = @"我的";
    mineVC.tabBarItem.image = [UIImage imageNamed:@"mine_icon_normal"];
    mineVC.tabBarItem.selectedImage = [[UIImage imageNamed:@"mine_icon_selected"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    BaseNavigationViewController * mineNav = [[BaseNavigationViewController alloc] initWithRootViewController:mineVC];
    
    SettingViewController * settingVC = [[SettingViewController alloc] init];
    settingVC.title = @"设置";
    settingVC.tabBarItem.image = [UIImage imageNamed:@"school_icon_normal"];
    settingVC.tabBarItem.selectedImage = [[UIImage imageNamed:@"school_icon_selected"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    BaseNavigationViewController * settingNav = [[BaseNavigationViewController alloc] initWithRootViewController:settingVC];
    
    self.viewControllers = @[ homeNav, centerNav, mineNav, settingNav ];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
