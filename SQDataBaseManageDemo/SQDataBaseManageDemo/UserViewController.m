//
//  UserViewController.m
//  SQDataBaseManageDemo
//
//  Created by lhq on 2018/3/8.
//  Copyright © 2018年 lhq. All rights reserved.
//

#import "UserViewController.h"
#import "SQUser.h"
#import "SQDataBaseManage.h"

@interface UserViewController ()  <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation UserViewController
- (void)addObject {
    
    SQUser *user = [[SQUser alloc] init];
    user.userId = @"90";
    user.name = @"南瓜";
    
    [SQDataBaseManage addObject:user whereType:DBWhereTypeUserInfo];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"User Table";
    
    SQUser *user = [SQDataBaseManage objectSingleWithWhereType:DBWhereTypeUserInfo];
    if (user) {
        _dataSource = [NSMutableArray arrayWithObject:user];
    }
    
    
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addObject)]];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    [self.view addSubview:_tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SQUser *user = _dataSource[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"userId:%@---%@",user.userId,user.name];
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        SQUser *user = _dataSource[indexPath.row];
        
        [SQDataBaseManage deleteObject:user whereType:DBWhereTypeUserInfo callback:^(BOOL result) {
            [_dataSource removeObject:user];
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView endUpdates];
        }];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
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

@end
