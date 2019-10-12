//
//  GCDProgramViewController.m
//  XYTest
//
//  Created by 张时疫 on 2019/9/17.
//  Copyright © 2019 张时疫. All rights reserved.
//

#import "GCDProgramViewController.h"

static NSString * const CELL_IDENTIFIER = @"CELL_IDENTIFIER";

@interface GCDProgramViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic , strong) UITableView * tableView;
@property (nonatomic , strong) NSMutableArray * dataSource;

@end

@implementation GCDProgramViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initSubviews];
    self.view.backgroundColor = HEXCOLOR(0xf9f9f9);
}

- (void)initSubviews {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view).insets(UIEdgeInsetsZero);
    }];
}

- (void)semaphoreTest {
    int data = 3;
    __block int mainData = 0;
    __block dispatch_semaphore_t sem = dispatch_semaphore_create(1);
    dispatch_queue_t queue = dispatch_queue_create("StudyBlocks", NULL);
    dispatch_async(queue, ^(void) {
        int sum = 0;
        for (int i = 0; i < 5; i++) {
            sum += data;
            NSLog(@" >> Sum: %d", sum);
        }
        dispatch_semaphore_signal(sem);
    });
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    for (int j = 0; j < 5; j++)  {
        mainData ++;
        NSLog(@">> Main Data: %d",mainData);
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark --- UITableViewDelegate ---
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [self semaphoreTest];
    } else if (indexPath.row == 1) {
        
    } else if (indexPath.row == 2) {
        
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
        _dataSource = [[NSMutableArray alloc] initWithArray:@[ @"semaphore信号量应用" ]];
    }
    return _dataSource;
}
@end
