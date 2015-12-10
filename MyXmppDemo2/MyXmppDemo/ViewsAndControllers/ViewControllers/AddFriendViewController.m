//
//  AddFriendViewController.m
//  MyXmppDemo
//
//  Created by 张广洋 on 15/11/29.
//  Copyright © 2015年 张广洋. All rights reserved.
//

#import "AddFriendViewController.h"

#import "XMPPManager.h"

@interface AddFriendViewController ()

@property (weak, nonatomic) IBOutlet UITextField *friendJidTF;

@end

@implementation AddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (IBAction)addFriendBtnClicked:(id)sender {
    if ((self.friendJidTF.text==nil )||[self.friendJidTF.text isEqualToString:@""]) {
        return;
    }
    [[XMPPManager manager]addFriendWithJid:self.friendJidTF.text];
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
