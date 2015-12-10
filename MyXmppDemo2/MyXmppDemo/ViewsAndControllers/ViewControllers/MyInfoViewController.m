//
//  MyInfoViewController.m
//  MyXmppDemo
//
//  Created by 张广洋 on 15/11/30.
//  Copyright © 2015年 张广洋. All rights reserved.
//

#import "MyInfoViewController.h"

#import "XMPPManager.h"

@interface MyInfoViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

@end

@implementation MyInfoViewController

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    XMPPvCardTemp * tmp=[[XMPPManager manager].xmppVCardTempModule myvCardTemp];
    self.headImageView.image=[UIImage imageWithData:[[XMPPManager manager].xmppVCardTempModule myvCardTemp].photo];
    NSLog(@"%@",tmp.nickname);
    NSLog(@"%@",tmp.bday);
    NSLog(@"%@",tmp.formattedName);
    NSLog(@"%@",tmp.familyName);
    NSLog(@"%@",tmp.givenName);
    NSLog(@"%@",tmp.middleName);
    NSLog(@"%@",tmp.addresses);
    NSLog(@"%@",tmp.emailAddresses);
    
}

-(void)didReceiveVcard:(NSNotification *)notf{
    NSLog(@"%@",notf.userInfo.allKeys[0]);
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
