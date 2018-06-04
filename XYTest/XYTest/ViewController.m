//
//  ViewController.m
//  XYTest
//
//  Created by 张时疫 on 2018/1/28.
//  Copyright © 2018年 张时疫. All rights reserved.
//

#import "ViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

#import "PermissionUtils.h"

#import <AddressBookUI/ABPeoplePickerNavigationController.h>
#import <AddressBook/ABPerson.h>
#import <AddressBookUI/ABPersonViewController.h>
#import <ContactsUI/ContactsUI.h>

#define LSY_CONTEXT 100

#define LSYEventVerbose(frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagVerbose, LSY_CONTEXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

@interface ViewController ()<ABPeoplePickerNavigationControllerDelegate,CNContactPickerDelegate>

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
    PermissionUtils * permissionUtils = [[PermissionUtils alloc] init];
    [permissionUtils checkLocationAuthorAuthorWithType:XYAuthorizationStatusWhenInUse callback:^(XYAuthorizationStatus status) {

    }];
//    [[PermissionUtils sharedInstance] openPermissionSetting];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
