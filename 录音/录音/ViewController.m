//
//  ViewController.m
//  录音
//
//  Created by jieku on 2017/5/9.
//  Copyright © 2017年 TSM. All rights reserved.
//

#import "ViewController.h"
#import "RecordController.h"
#import "Common.h"

@interface ViewController ()

@property (nonatomic ,strong)UIButton *clickBtn ;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    _clickBtn= [Common createBtnFrame:CGRectMake(100, 100, 200, 50) type:UIButtonTypeCustom target:self action:@selector(click) title:@"点击进入录音"];
    _clickBtn.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.clickBtn];
}

-(void)click{
    
    RecordController *rvc = [[RecordController alloc]init];
    UINavigationController *nv = [[UINavigationController alloc]initWithRootViewController:rvc];
    [self presentViewController:nv animated:YES completion:nil];
}


@end
