//
//  ViewController.m
//  Demo
//
//  Created by lhq on 2018/3/2.
//  Copyright © 2018年 lhq. All rights reserved.
//

#import "ViewController.h"
#import "SQDataBaseManage.h"
#import "HomeCoupon.h"

@interface ViewController () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation ViewController
- (void)addObject {
    HomeCoupon *coupon = [[HomeCoupon alloc] init];
    coupon.title = [NSString stringWithFormat:@"商品标题%u",arc4random() % 100];
    coupon.couponId = [NSString stringWithFormat:@"%u",arc4random() % 100 + 100];
    coupon.timestamp = NSTimeIntervalSince1970;
    coupon.history = YES;
    
    [SQDataBaseManage addObject:coupon whereType:DBWhereTypeHistory callback:^(BOOL result) {
        if (result) {
            [_dataSource insertObject:coupon atIndex:0];
            [_tableView reloadData];
        }
    }];
}

- (void)deleteObjects {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"Database Demo";
    
    NSArray *arr = [SQDataBaseManage objectsWithDBWhereType:DBWhereTypeHistory page:0 pageSize:100];
    _dataSource = [NSMutableArray arrayWithArray:arr];
    
    self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteObjects)]];
    
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
    HomeCoupon *coupon = _dataSource[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"couponId:%@---%@",coupon.couponId,coupon.title];
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        HomeCoupon *coupon = _dataSource[indexPath.row];
        
        [SQDataBaseManage deleteObject:coupon whereType:DBWhereTypeHistory callback:^(BOOL result) {
            [_dataSource removeObject:coupon];
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


@end
