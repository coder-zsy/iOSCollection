//
//  ViewController.m
//  XYTest
//
//  Created by 张时疫 on 2018/1/28.
//  Copyright © 2018年 张时疫. All rights reserved.
//

#import "SettingViewController.h"
#import "PermissionUtils.h"
#import "AudioViewController.h"
#import "WebViewController.h"
#import "WKWebViewController.h"
#import "XYImagePickerController.h"

static NSString * const CELL_IDENTIFIER = @"CELL_IDENTIFIER";

@interface SettingViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic , strong) UITableView * tableView;
@property (nonatomic , strong) NSMutableArray * dataSource;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initSubviews];
    self.view.backgroundColor = HEXCOLOR(0xf9f9f9);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"XYChangeStatusBarNotification" object:self userInfo:@{ @"type": @"hide" }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

- (void)initSubviews {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view).insets(UIEdgeInsetsZero);
    }];
}

- (void)imagepickerAction {
    XYImagePickerController * imagePickerVC = [[XYImagePickerController alloc] init];
    [self.navigationController pushViewController:imagePickerVC animated:YES];
    return;
    // PermissionUtils * permissionUtils = [[PermissionUtils alloc] init];
    // [[PermissionUtils sharedManager] checkLocationAuthorAuthorWithType:XYAuthorizationStatusWhenInUse callback:^(XYAuthorizationStatus status) {
    //      NSLog(@"===========,%ld", (long)status);
    // }];
    // [[PermissionUtils sharedInstance] openPermissionSetting];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --- UITableViewDelegate ---
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [self imagepickerAction];
    } else if (indexPath.row == 1) {
        AudioViewController * vc = [[AudioViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.row == 2) {
        WKWebViewController * wkWebController = [[WKWebViewController alloc] init];
        [self.navigationController pushViewController:wkWebController animated:YES];
        return;
        if (iOS9Later) {
            WKWebViewController * wkWebController = [[WKWebViewController alloc] init];
            [self.navigationController pushViewController:wkWebController animated:YES];
        } else {
            WebViewController * webController = [[WebViewController alloc] init];
            [self.navigationController pushViewController:webController animated:YES];
        }
    }
}

#pragma mark --- UITableViewDataSource ---
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
    }
    cell.backgroundColor = RGB(255, 255, 255);
    cell.textLabel.text = [self.dataSource objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark --- Getter ---
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorInset = UIEdgeInsetsZero;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return _tableView;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] initWithArray:@[ @"图片/视频选择器", @"音乐播放测试", @"webview 测试" ]];
    }
    return _dataSource;
}

@end
