//
//  FriendsViewController.m
//  MyXmppDemo
//
//  Created by 张广洋 on 15/12/5.
//  Copyright © 2015年 张广洋. All rights reserved.
//

#import "FriendsViewController.h"

#import "UIView+autoLayout.h"

@interface FriendsViewController ()

@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startShelter];
}

-(void)startShelter{
    //隐藏导航栏和标签栏
    [self.navigationController setNavigationBarHidden:YES];
    self.tabBarController.tabBar.hidden=YES;
    //自己加载图片作为遮挡
    UIImageView * shelterImgV=[[UIImageView alloc]init];
    shelterImgV.image=[UIImage imageNamed:@"welcome_bg1.png"];
    [self.view addSubview:shelterImgV];
    shelterImgV.leading=0;
    shelterImgV.top=0;
    shelterImgV.bottom=0;
    shelterImgV.widthHeightAspactRatio=2496/1146.0;
    //登陆界面
    __weak typeof(self) weakSelf = self;
    UIViewController * loginVC=[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"the_login_VC"];
    [self presentViewController:loginVC animated:NO completion:^{
        [shelterImgV removeFromSuperview];
        [weakSelf.navigationController setNavigationBarHidden:NO];
        weakSelf.tabBarController.tabBar.hidden=NO;
    }];
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
