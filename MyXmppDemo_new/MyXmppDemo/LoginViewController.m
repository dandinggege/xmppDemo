//
//  LoginViewController.m
//  MyXmppDemo
//
//  Created by 张广洋 on 15/12/5.
//  Copyright © 2015年 张广洋. All rights reserved.
//

#import "LoginViewController.h"

#import "MyMusicPlayer.h"

#import "UIView+autoLayout.h"

#import "MyHeader.h"

#import "MySecurity.h"

#import "XMPPManager.h"

#import "MyUIFactory.h"

#import "PhotoViewController.h"

@interface LoginViewController ()
<UITextFieldDelegate>

//域输入文本框
@property (weak, nonatomic) IBOutlet UITextField *domainNameTF;
//用户名输入文本框
@property (weak, nonatomic) IBOutlet UITextField *usernameTF;
//用户密码输入文本框
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //播放风声的背景音乐。
    [[MyMusicPlayer player]playWindBgSound];
    //读取显示上次登录用户信息
    [self getLastLoginUserInfo];
}

-(void)getLastLoginUserInfo{
    NSUserDefaults * standardUD=[NSUserDefaults standardUserDefaults];
    NSDictionary * lastUserInfo=[standardUD objectForKey:ZGY_LAST_LOGIN_USER_INFO];
    if (lastUserInfo) {
        NSString * domainNameStr=[lastUserInfo objectForKey:ZGY_MD5(@"domainName")];
        NSString * userNameStr=[lastUserInfo objectForKey:ZGY_MD5(@"userName")];
        NSString * passwordStr=[lastUserInfo objectForKey:ZGY_MD5(@"password")];
        self.domainNameTF.text=[MySecurity strFromBase64Str:domainNameStr];
        self.usernameTF.text=[MySecurity strFromBase64Str:userNameStr];
        self.passwordTF.text=[MySecurity strFromBase64Str:passwordStr];
    }else{
        self.domainNameTF.text=@"zhangguangyangdemacbook-pro.local";
    }
}

-(void)viewWillAppear:(BOOL)animated{
    //设置左标题
        //服务器
    UILabel * serverLabel=[[UILabel alloc]initWithFrame:CGRectMake(2, 2, 60, 36)];
    serverLabel.backgroundColor=[UIColor clearColor];
    serverLabel.text=@"服务器:";
    serverLabel.textAlignment=NSTextAlignmentRight;
    serverLabel.textColor=[UIColor blueColor];
    self.domainNameTF.leftView=serverLabel;
    self.domainNameTF.leftViewMode=UITextFieldViewModeAlways;
        //用户名
    UILabel * userNameLabel=[[UILabel alloc]initWithFrame:CGRectMake(2, 2, 60, 36)];
    userNameLabel.backgroundColor=[UIColor clearColor];
    userNameLabel.text=@"用户名:";
    userNameLabel.textAlignment=NSTextAlignmentRight;
    userNameLabel.textColor=[UIColor blueColor];
    self.usernameTF.leftView=userNameLabel;
    self.usernameTF.leftViewMode=UITextFieldViewModeAlways;
        //密码
    UILabel * passwordLabel=[[UILabel alloc]initWithFrame:CGRectMake(2, 2, 60, 36)];
    passwordLabel.backgroundColor=[UIColor clearColor];
    passwordLabel.text=@"密码:";
    passwordLabel.textAlignment=NSTextAlignmentRight;
    passwordLabel.textColor=[UIColor blueColor];
    self.passwordTF.leftView=passwordLabel;
    self.passwordTF.leftViewMode=UITextFieldViewModeAlways;
    //显示欢迎背景图片
    UIImageView * shelterImgV=[[UIImageView alloc]init];
    shelterImgV.image=[UIImage imageNamed:@"welcome_bg1.png"];
    [self.view addSubview:shelterImgV];
    shelterImgV.leading=0;
    shelterImgV.top=0;
    shelterImgV.bottom=0;
    shelterImgV.widthHeightAspactRatio=2496/1146.0;
    [UIView animateWithDuration:2.0 animations:^{
        shelterImgV.alpha=0;
    } completion:^(BOOL finished) {
        [shelterImgV removeFromSuperview];
    }];
}


#pragma mark - 按钮触发的事件 -

//登陆
- (IBAction)loginBtnClicked:(id)sender {
    [self loginOrRegister:NO];
}

//注册
- (IBAction)registerBtnClicked:(id)sender {
    [self loginOrRegister:YES];
}

-(void)loginOrRegister:(BOOL)isRegister{
    //结束键盘编辑
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    [[MyMusicPlayer player]playWater0];
    //判断输入是否合法
    if (self.domainNameTF.text==nil ||
        [self.domainNameTF.text isEqualToString:@""]||
        self.usernameTF.text==nil ||
        [self.usernameTF.text isEqualToString:@""]||
        self.passwordTF.text==nil ||
        [self.passwordTF.text isEqualToString:@""]) {
        [[MyMusicPlayer player]playWater1];
        [MyUIFactory showMsg:@"请填写完整信息！" withVC:self];
        return;
    }
    //传递用户信息
    [XMPPManager manager].doMainName=self.domainNameTF.text;
    [XMPPManager manager].userName=self.usernameTF.text;
    [XMPPManager manager].password=self.passwordTF.text;
    //执行登陆／注册
    if (isRegister) {
        [[XMPPManager manager] registerWithCallBack:^(BOOL success, NSError * error) {
            if (success) {
                NSLog(@"VC:注册成功，下一步进行授权（不授权无法上传头像）");
                [[XMPPManager manager]authenticateWithCallBack:^(BOOL success, NSError * error) {
                    if (success) {
                        NSLog(@"VC:注册后授权成功");
                        [[XMPPManager manager]updateHeadImage:[UIImage imageNamed:@"headPhoto.png"] name:@"x8" nickName:@"xx8xx" email:@"xy8" address:@"xz8"];
                        PhotoViewController * photoVC=[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"photo_VC"];
                        [self presentViewController:photoVC animated:YES completion:nil];
                    }else{
                        NSLog(@"VC:注册后授权失败");
                    }
                   
                }];
            }else{
                NSLog(@"VC:注册失败");
            }
        }];
    }else{
        //执行登陆操作
        [[XMPPManager manager] loginWithCallBack:^(BOOL success, NSError * error) {
            if (success) {
                NSLog(@"VC：哎哟，登陆成功哦！");
                NSLog(@"photo:---%@",[[XMPPManager manager].xmppVCardTempModule myvCardTemp].photo);
                //关闭背景音乐
                [[MyMusicPlayer player]stop];
                //保存用户登陆信息
                [self saveLastUserInfo];
                //登陆界面消失
                [self dismissViewControllerAnimated:YES completion:nil];
            }else{
                NSLog(@"VC：登陆失败咯，嘿嘿嘿!");
            }
        }];
    }
}

//如果登陆成功，执行保存用户信息操作
-(void)saveLastUserInfo{
    NSString * domainNameStr=[MySecurity base64StrFromStr:self.domainNameTF.text];
    NSString * usernameStr=[MySecurity base64StrFromStr:self.usernameTF.text];
    NSString * passwordStr=[MySecurity base64StrFromStr:self.passwordTF.text];
    NSDictionary * dic=@{ZGY_MD5(@"domainName"):domainNameStr,ZGY_MD5(@"userName"):usernameStr,ZGY_MD5(@"password"):passwordStr};
    [[NSUserDefaults standardUserDefaults]setObject:dic forKey:ZGY_LAST_LOGIN_USER_INFO];
    [[NSUserDefaults standardUserDefaults]synchronize];
}


#pragma mark - textField代理方法 -

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField==self.domainNameTF) {
        [self.usernameTF becomeFirstResponder];
    }else if(textField==self.usernameTF){
        [self.passwordTF becomeFirstResponder];
    }else{
        [self.passwordTF resignFirstResponder];
    }
    return YES;
}


#pragma mark - 其他方法 -

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
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
