//
//  ViewController.m
//  XYTest
//
//  Created by 张时疫 on 2018/1/28.
//  Copyright © 2018年 张时疫. All rights reserved.
//

#import "ViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "PermissionCheckTools.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton * openButton = [UIButton buttonWithType:UIButtonTypeCustom];
    openButton.frame = CGRectMake(100, 200, 80, 44);
    [openButton setTitle:@"打开" forState: UIControlStateNormal];
    [openButton setBackgroundColor:[UIColor redColor]];
    [openButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [openButton addTarget:self action:@selector(imagepickerAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:openButton];
}

- (void)imagepickerAction:(UIButton *)button {
//    [[PermissionCheckTools sharedInstance] checkLocationAuthorAuthorWithType:XYAuthorizationStatusWhenInUse callback:^(XYAuthorizationStatus status) {
//
//    }];
    [[PermissionCheckTools sharedInstance] openPermissionSetting];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
