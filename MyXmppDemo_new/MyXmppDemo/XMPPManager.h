//
//  XMPPManager.h
//  MyXmppDemo
//
//  Created by 张广洋 on 15/12/5.
//  Copyright © 2015年 张广洋. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#import "XMPPStream.h"
#import "XMPPJID.h"
#import "XMPPPresence.h"

#import "XMPPvCardTemp.h"
#import "XMPPvCardCoreDataStorage.h"

//定义注册登录的block类型
typedef void(^CompleteCallBack) (BOOL,NSError*);


@interface XMPPManager : NSObject

//获取单例对象
+(instancetype)manager;
//用户名称
@property (nonatomic,copy) NSString * userName;
//用户密码
@property (nonatomic,copy) NSString * password;
//登陆的域
@property (nonatomic,copy) NSString * doMainName;
//提示依托的vc
@property (nonatomic,weak) UIViewController * aVC;

//个人信息名片
@property (nonatomic,strong)XMPPvCardTempModule * xmppVCardTempModule;

#pragma mark - 登陆和注册接口 -

//使用xmppstream来和服务端进行网络通讯
//内部包含socket，使用tcp协议
@property (nonatomic,strong) XMPPStream *xmmpStream;

//注册接口
-(void)registerWithCallBack:(CompleteCallBack)callBack;
//授权，用于注册成功以后
-(void)authenticateWithCallBack:(CompleteCallBack)callBack;
//登陆接口
-(void)loginWithCallBack:(CompleteCallBack)callBack;
//等出
-(void)logOut;

//上传个人信息
-(void)updateHeadImage:(UIImage *)image
                  name:(NSString *)name
              nickName:(NSString *)nickName
                 email:(NSString *)email
               address:(NSString *)address;
//获取jid对应的名片信息
-(void)getVCardWithJid:(NSString *)jid;

@end
