//
//  XMPPManager.m
//  MyXmppDemo
//
//  Created by 张广洋 on 15/12/5.
//  Copyright © 2015年 张广洋. All rights reserved.
//

#import "XMPPManager.h"

#import "MyUIFactory.h"

#import "MyHeader.h"

#import "ZGYBase64Encode.h"

@interface XMPPManager()
<XMPPStreamDelegate,XMPPvCardAvatarDelegate,XMPPvCardTempModuleDelegate>
{
    //用来标记是登陆还是注册的布尔值，YES表示执行注册功能，NO，表示执行登陆功能
    BOOL _IS_REGISTER;
}

//持有回调block
@property (nonatomic,copy)CompleteCallBack callBack;

//获取个人名片／上传个人名片
@property (nonatomic,strong)XMPPvCardCoreDataStorage * xmppVCardCoreDataStorage;
@property (nonatomic,strong)XMPPvCardAvatarModule * xmppVCardAvatarModule;

@end

@implementation XMPPManager

-(void)dealloc{
}

-(instancetype)init{
    if (self=[super init]) {
        //初始化xmppStream
        self.xmmpStream = [[XMPPStream alloc]init];
        //设置xmppstream连接的服务器
        self.xmmpStream.hostName = @"zhangguangyangdemacbook-pro.local";
        //设置xmppStream连接的端口号
        self.xmmpStream.hostPort = 5222;
        //当有网络事件发生调用自己的相应的代理方法
        [self.xmmpStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        //名片相关的初始化操作
        self.xmppVCardCoreDataStorage=[XMPPvCardCoreDataStorage sharedInstance];
        self.xmppVCardTempModule=[[XMPPvCardTempModule alloc]initWithvCardStorage:self.xmppVCardCoreDataStorage];
        self.xmppVCardAvatarModule=[[XMPPvCardAvatarModule alloc]initWithvCardTempModule:self.xmppVCardTempModule];
        [self.xmppVCardTempModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [self.xmppVCardAvatarModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

+(instancetype)manager{
    static XMPPManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[XMPPManager alloc]init];
    });
    return manager;
}


#pragma mark - 登陆注册接口 -

-(void)registerWithCallBack:(CompleteCallBack)callBack{
    _IS_REGISTER=YES;
    //设置服务器域
    self.xmmpStream.hostName = self.doMainName;
    //开始连接服务器
    [self connectToHostWithCompleteHandle:callBack];
}

-(void)authenticateWithCallBack:(CompleteCallBack)callBack{
    self.callBack=callBack;
    [self.xmmpStream authenticateWithPassword:self.password error:nil];
}

-(void)loginWithCallBack:(CompleteCallBack)callBack{
    _IS_REGISTER=NO;
    //设置服务器域
    self.xmmpStream.hostName = self.doMainName;
    //开始连接服务器
    [self connectToHostWithCompleteHandle:callBack];
}

-(void)logOut{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [self.xmmpStream sendElement:presence];
    [self.xmmpStream disconnect];
}

-(void)updateHeadImage:(UIImage *)image
                  name:(NSString *)name
              nickName:(NSString *)nickName
                 email:(NSString *)email
               address:(NSString *)address{
    dispatch_queue_t  global_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(global_queue, ^{
        NSXMLElement *vCardXML = [NSXMLElement elementWithName:@"vCard"];
        [vCardXML addAttributeWithName:@"xmlns" stringValue:@"vcard-temp"];
        NSXMLElement *photoXML = [NSXMLElement elementWithName:@"PHOTO"];
        NSXMLElement *typeXML = [NSXMLElement elementWithName:@"TYPE" stringValue:@"image/jpeg"];
        
        NSData *dataFromImage = UIImageJPEGRepresentation(image, 1.0);//图片放缩
        NSXMLElement *binvalXML = [NSXMLElement elementWithName:@"BINVAL" stringValue:[ZGYBase64Encode base64StrFromData:dataFromImage]];
        [photoXML addChild:typeXML];
        [photoXML addChild:binvalXML];
        [vCardXML addChild:photoXML];
        
        XMPPvCardTemp * myvCardTemp = [self.xmppVCardTempModule myvCardTemp];
        if (myvCardTemp) {
            myvCardTemp.photo = dataFromImage;
//            myvCardTemp.name = name;
            myvCardTemp.nickname = nickName;
//            myvCardTemp.addresses = @[address];
//            myvCardTemp.emailAddresses = @[email];
            [self.xmppVCardTempModule activate: self.xmmpStream];
            [self.xmppVCardTempModule updateMyvCardTemp:myvCardTemp];
        } else {
            XMPPvCardTemp *newvCardTemp = [XMPPvCardTemp vCardTempFromElement:vCardXML];
//            newvCardTemp.name = name;
            newvCardTemp.nickname = nickName;
//            newvCardTemp.addresses = @[address];
//            newvCardTemp.emailAddresses = @[email];
            [self.xmppVCardTempModule activate: self.xmmpStream];
            [self.xmppVCardTempModule updateMyvCardTemp:newvCardTemp];
        }
    });
}

-(void)getVCardWithJid:(NSString *)jid{
    XMPPJID * xmppJid=[XMPPJID jidWithString:jid];
    [self.xmppVCardTempModule fetchvCardTempForJID:xmppJid ignoreStorage:NO];
}


#pragma mark - 连接服务器 -

-(void)connectToHostWithCompleteHandle:(CompleteCallBack)callBack
{
    self.callBack = callBack;
    //使用用户名和密码进行注册,由于xmppstream使用的是tcp协议，需要首先建立连接
    //建立连接的过程
    //首先对xmppstream设置jid
    //JID 在xmpp协议中唯一表示一个用户
    //格式：user@domain/resource,采用邮箱格式进行注册
    //resource:可以用来区分终端用，这个是可选的
    
    //保证连接一次
    if ([self.xmmpStream isConnected]) {
        [self.xmmpStream disconnect];
    }
    
    [self.xmmpStream setMyJID:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",self.userName,self.doMainName]]];
    //连接服务器
    NSError *error;
    [self.xmmpStream connectWithTimeout:-1 error:&error];
    //NSLog(@"%@",error.localizedDescription);
}


#pragma mark - xmppStream代理方法 -

//当与服务器建立连接之后调用的代理放
-(void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"xmpp连接服务器成功");
    if(_IS_REGISTER){
        NSLog(@"xmpp开始注册用户");
        [self.xmmpStream registerWithPassword:self.password error:nil];
    }else{
        NSLog(@"xmpp开始登陆用户");
        [self.xmmpStream authenticateWithPassword:self.password error:nil];
    }
}

//连接服务器失败
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    NSLog(@"xmpp连接服务器失败:%@",error);
    [MyUIFactory showMsg:STR_COMBIN(@"xmpp连接服务器失败:", error) withVC:self.aVC];
}
//注册成功之后的代理方法
-(void)xmppStreamDidRegister:(XMPPStream *)sender
{
    NSLog(@"注册成功");
    if (self.callBack) {
        self.callBack(YES,nil);
    }
}
//注册失败后的代理方法
-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{
    //获取个人名片信息
    [self.xmppVCardAvatarModule activate:self.xmmpStream];
    [self.xmppVCardTempModule activate:self.xmmpStream];
    NSLog(@"注册失败:%@",error);
    if (self.callBack) {
        NSError *myError = [NSError errorWithDomain:error.description code:1000 userInfo:nil];
        self.callBack(NO,myError);
    }
}
//认证成功后调用的代理方法
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    //获取个人名片信息
    [self.xmppVCardAvatarModule activate:self.xmmpStream];
    [self.xmppVCardTempModule activate:self.xmmpStream];
    //登陆成功的回调
    if (self.callBack) {
        self.callBack(YES,nil);
    }
    [self onLine];
}

//认证失败调用的代理方法
-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    if (self.callBack) {
        NSError *myError = [NSError errorWithDomain:error.description code:1000 userInfo:nil];
        self.callBack(NO,myError);
    }
}


#pragma mark - 更新明信片结果 -

- (void)xmppvCardTempModuleDidUpdateMyvCard:(XMPPvCardTempModule *)vCardTempModule{
    NSLog(@"更新个人明信片成功！");
}

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule failedToUpdateMyvCard:(NSXMLElement *)error{
    NSLog(@"更新个人明信片失败:->%@",error);
}

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule
        didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp
                     forJID:(XMPPJID *)jid{
    NSLog(@"didReceivevCardTemp－》%@ －》%@ －》%@",vCardTempModule,vCardTemp,jid);
}

-(void)xmppvCardAvatarModule:(XMPPvCardAvatarModule *)vCardTempModule didReceivePhoto:(UIImage *)photo forJID:(XMPPJID *)jid{
    NSLog(@"获取到－》%@ －》%@",photo,jid);
}


#pragma mark - 其他自定义方法 -

//<presence/>发送在线消息给服务器
-(void)onLine
{
    //XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    //发送presence节到服务端
    XMPPPresence *presence = [XMPPPresence presence];
    [self.xmmpStream sendElement:presence];
}

@end
