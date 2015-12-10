//
//  XMPPManager.h
//  
//
//  Created by 张广洋 on 15/11/15.
//
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#import "MessageModel.h"

#import "XMPPvCardTemp.h"

#import "XMPPvCardCoreDataStorage.h"

//定义注册登录的block类型
typedef void(^CompleteCallBack) (BOOL,NSError*);

//更新用户列表的广播名称
#define UPDATE_FRIEND_LIST (@"UPDATE_FRIEND_LIST")
//收到用户消息的通知名称
#define RECEIVE_MESSAGE (@"RECEIVE_MESSAGE")

#define DID_RECEIVE_VCARD (@"DID_RECEIVE_VCARD")


@interface XMPPManager : NSObject

//获取单例对象
+(instancetype)manager;
//用户名称
@property (nonatomic,copy) NSString * userName;
//用户密码
@property (nonatomic,copy) NSString * password;
//登陆的域
@property (nonatomic,copy) NSString * doMainName;

@property (nonatomic)XMPPvCardTempModule * xmppVCardTempModule;

//注册接口
-(void)registerWithCallBack:(CompleteCallBack)callBack;
//登陆接口
-(void)loginWithCallBack:(CompleteCallBack)callBack;

//获取用户列表：每个元素是FriendModel对象
-(NSMutableArray *)getFriendList;

//发送消息给好友
-(void)sendMessage:(MessageModel *)messageModel;


//添加好友
-(void)addFriendWithJid:(NSString *)jid;

//删除好友
-(void)deleteFriendWithJid:(NSString *)jid;

//请求联系人名片
-(void)fetchvCardTempForJid:(NSString *)jid;

//上传头像
-(void)updateHeadImage:(UIImage *)image;

//


@end
