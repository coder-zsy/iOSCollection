//
//  HomeViewController.m
//  XYTest
//
//  Created by 张时疫 on 2019/4/29.
//  Copyright © 2019 张时疫. All rights reserved.
//

#import "HomeViewController.h"
#import "DeviceInfoUtils.h"

static NSString * const CELL_IDENTIFIER = @"CELL_IDENTIFIER";

@interface HomeViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic , strong) UITableView * tableView;
@property (nonatomic , strong) NSMutableArray * dataSource;

@property (nonatomic, copy) NSString * batteryLevel;
@property (nonatomic, copy) NSString * batteryState;

@end

@implementation HomeViewController

#pragma mark --- life circle ---

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //    [self setNeedsStatusBarAppearanceUpdate];
    [self initSubviews];
    [self initDataSource];
    self.view.backgroundColor = HEXCOLOR(0xf9f9f9);
}

- (void)viewWillAppear:(BOOL)animated {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

#pragma mark --- UITableViewDelegate ---
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        
    } else if (indexPath.row == 1) {
        
    } else if (indexPath.row == 2) {
        
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}
//- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return [NSString stringWithFormat:@"区头:%ld",(long)section];
//}

#pragma mark --- UITableViewDataSource ---
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray * sectionArray = [self.dataSource objectAtIndex:section];
    return sectionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CELL_IDENTIFIER];
    }
    cell.backgroundColor = RGB(255, 255, 255);
    NSArray * sectionArray = [self.dataSource objectAtIndex:indexPath.section];
    cell.textLabel.text = [sectionArray objectAtIndex:indexPath.row];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.detailTextLabel.text = [DeviceInfoUtils getAppVersion];
        }
    } else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            cell.detailTextLabel.text = [DeviceInfoUtils getSystemVersion];
        } else if (indexPath.row == 1) {
            cell.detailTextLabel.text = [DeviceInfoUtils deviceModelName];
        } else if (indexPath.row == 2) {
            cell.detailTextLabel.text = self.batteryLevel;
        } else if (indexPath.row == 3) {
            cell.detailTextLabel.text = self.batteryState;
        }
    } else if (indexPath.section == 2) {
        
        if (indexPath.row == 0) { // @"运营商",
            cell.detailTextLabel.text = [DeviceInfoUtils getOperatorInfo];
        } else if (indexPath.row == 1) { // @"IMSI",
            cell.detailTextLabel.text = [DeviceInfoUtils getIMSI];
        } else if (indexPath.row == 2) { // @"网络状态",
            cell.detailTextLabel.text = [[DeviceInfoUtils getNetworkType] objectForKey:@"network"];
        } else if (indexPath.row == 3) { // @"网络等级",
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[[DeviceInfoUtils getNetworkType] objectForKey:@"network_level"]];
//            cell.detailTextLabel.text = @"测试中..";
        } else if (indexPath.row == 4) { // @"IP地址",
            cell.detailTextLabel.text = [DeviceInfoUtils getIPAddress];
        } else if (indexPath.row == 5) { // @"WIFI SSID",
            cell.detailTextLabel.text = [DeviceInfoUtils getWifiSSID];
        } else if (indexPath.row == 6) { // @"WIFI BSSID",
            cell.detailTextLabel.text = [DeviceInfoUtils getWifiBSSID];
        } else if (indexPath.row == 7) { // @"WIFI等级",
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[[DeviceInfoUtils getNetworkType] objectForKey:@"wifi_level"]];
        } else if (indexPath.row == 8) { // @"WIFI 强度"
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[[DeviceInfoUtils getNetworkType] objectForKey:@"wifi_strength"]];
        }
    } else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            cell.detailTextLabel.text = [DeviceInfoUtils isDevicePrisionBreak] ? @"是" : @"否";
        }
    }
    return cell;
}

- (void)initDataSource {
    CGFloat batteryValue = [DeviceInfoUtils getDeviceBattery];
    self.batteryLevel = batteryValue == -1 ? @"未知" : [NSString stringWithFormat:@"%.0f%%",batteryValue*100];
    NSInteger batteryState = [DeviceInfoUtils getDeviceBatteryStatus];
    self.batteryState = batteryState == 1 ? @"放电中（未充电）" : batteryState == 2 ? @"充电中" : batteryState == 3 ? @"充电中（已充满）" : @"未知状态";
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceBatteryLevelDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        CGFloat batteryValue = [DeviceInfoUtils getDeviceBattery];
        self.batteryLevel = batteryValue == -1 ? @"未知" : [NSString stringWithFormat:@"%.0f%%",batteryValue*100];
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:2 inSection:1];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
     }];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceBatteryStateDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSInteger batteryState = [DeviceInfoUtils getDeviceBatteryStatus];
        self.batteryState = batteryState == 1 ? @"放电中（未充电）" : batteryState == 2 ? @"充电中" : batteryState == 3 ? @"充电中（已充满）" : @"未知状态";
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:3 inSection:1];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }];
}

- (void)initSubviews {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view).insets(UIEdgeInsetsZero);
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark --- Getter ---
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
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
        _dataSource = [[NSMutableArray alloc] initWithObjects:@[
                                                                @"App版本"
                                                                ], @[
                                                                     @"系统版本",@"设备型号",@"电池电量",@"充电状态"
                                                                     ], @[
                                                                         @"运营商",@"IMSI",@"网络状态",@"网络等级",@"IP地址",@"WIFI SSID",@"WIFI BSSID",@"WIFI等级",@"WIFI 强度"
                                                                         ], @[
                                                                             @"是否越狱",
                                                                             ], nil];
    }
    return _dataSource;
}


@end
