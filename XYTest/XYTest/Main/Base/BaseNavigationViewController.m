//
//  BaseNavigationViewController.m
//  jiedanyi3
//
//  Created by 张时疫 on 2018/4/19.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "BaseNavigationViewController.h"

@interface BaseNavigationViewController ()

@end

@implementation BaseNavigationViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
//    UIViewController* topVC = self.topViewController;
//    return [topVC preferredStatusBarStyle];
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
//    UIViewController* topVC = self.topViewController;
//    return [topVC prefersStatusBarHidden];
    return YES;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
 //  self.navigationController.interactivePopGestureRecognizer.delegate = self;
     [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - 控制屏幕旋转方法
//是否自动旋转,返回YES可以自动旋转,返回NO禁止旋转
- (BOOL)shouldAutorotate {
  return [[self.viewControllers lastObject] shouldAutorotate];
}

//支持屏幕旋转种类
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
  //  return UIInterfaceOrientationMaskPortrait;
  return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

//由模态推出的视图控制器 优先支持的屏幕方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
  return UIInterfaceOrientationPortrait;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
  // 初始化rootViewController
  if ([[self viewControllers] count] == 0) {
    [super pushViewController:viewController animated:animated];
    return;
  }
  
  UIViewController *rootController;
  if (self.parentViewController) {
    rootController = self.parentViewController;
  } else {
    rootController = self;
  }
  
  // 从带tabbar的页面push到 不带tabbar的页面
  if ([rootController isKindOfClass:[UITabBarController class]] && [[self viewControllers] count] == 1) {
    //隐藏tabBar
    viewController.hidesBottomBarWhenPushed = YES;
  }
  [super pushViewController:viewController animated:animated];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark --- UINavigationControllerDelegate ---

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
  XYLog(@"willShowViewController：navigationController%@\nviewController:%@",navigationController, viewController);
}
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    XYLog(@"didShowViewController：%@\nviewController:%@",navigationController, viewController);
}

//- (UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController { }
//- (UIInterfaceOrientation)navigationControllerPreferredInterfaceOrientationForPresentation:(UINavigationController *)navigationController { }

//- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController {
//
//}

//- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
//
//}
@end
