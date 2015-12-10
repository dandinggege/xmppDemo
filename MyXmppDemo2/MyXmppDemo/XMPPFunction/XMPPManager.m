//
//  XMPPManager.m
//  
//
//  Created by 张广洋 on 15/11/15.
//
//

#import "XMPPManager.h"

#import "XMPPJID.h"
#import "XMPPResource.h"
#import "XMPPStream.h"
#import "NSXMLElement+XMPP.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPRoster.h"



#import "FriendModel.h"

#import "ZGYBase64Encode.h"

@interface  XMPPManager()
<XMPPStreamDelegate,XMPPRosterDelegate,XMPPvCardTempModuleDelegate,XMPPvCardAvatarDelegate>
{
    //是否执行注册操作；YES表示注册，NO表示登陆
    BOOL _IS_REGISTER;
    //用户列表
    NSMutableArray * _userFriendsArr;
}

//使用xmppstream来和服务端进行网络通讯
//内部包含socket，使用tcp协议
@property (nonatomic)XMPPStream *xmmpStream;

//添加好友要求
@property (nonatomic)XMPPRosterCoreDataStorage * xmppRosterCoreDataStorage;
//xmpp花名册
@property (nonatomic)XMPPRoster * xmppRoster;

@property (nonatomic)XMPPvCardCoreDataStorage * xmppVCardCoreDataStorage;
@property (nonatomic)XMPPvCardAvatarModule * xmppVCardAvatarModule;


//持有回调block
@property (nonatomic,copy)CompleteCallBack callBack;

@end

@implementation XMPPManager

-(void)dealloc{
}

-(instancetype)init{
    if (self=[super init]) {
        //实例化
        _userFriendsArr=[[NSMutableArray alloc]init];
        
        
        //初始化xmppStream
        self.xmmpStream = [[XMPPStream alloc]init];
        //设置xmppstream连接的服务器
        self.xmmpStream.hostName = @"zhangguangyangdemacbook-pro.local";
        //设置xmppStream连接的端口号
        self.xmmpStream.hostPort = 5222;
        //当有网络事件发生调用自己的相应的代理方法
        [self.xmmpStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        
        self.xmppRosterCoreDataStorage = [[XMPPRosterCoreDataStorage alloc] init];
        //花名册
        self.xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:self.xmppRosterCoreDataStorage];
        
        
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

#pragma mark - 相关接口等等 -

-(void)registerWithCallBack:(CompleteCallBack)callBack{
    _IS_REGISTER=YES;
    //设置服务器域
    self.xmmpStream.hostName = self.doMainName;
    //开始连接服务器
    [self connectToHostWithCompleteHandle:callBack];
}

-(void)loginWithCallBack:(CompleteCallBack)callBack{
    _IS_REGISTER=NO;
    //设置服务器域
    self.xmmpStream.hostName = self.doMainName;
    //开始连接服务器
    [self connectToHostWithCompleteHandle:callBack];
}

-(NSMutableArray *)getFriendList{
    return _userFriendsArr;
}

-(void)sendMessage:(MessageModel *)messageModel{
    //构建message节
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat"];
    //to属性
    [message addAttributeWithName:@"to" stringValue:messageModel.toJid];
    //from属性
    [message addAttributeWithName:@"from" stringValue:messageModel.fromJid];
    //xml:lang属性
    [message addAttributeWithName:@"xml:lang" stringValue:@"en"];
    //构建body子结点
    NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:messageModel.message];
    //把body添加为message的子结点
    [message addChild:body];
    //发送messag节到服务器
    [self.xmmpStream sendElement:message];
}

-(void)addFriendWithJid:(NSString *)jid{
    XMPPJID *friendJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",jid,self.doMainName] ];
    [self.xmppRoster subscribePresenceToUser:friendJID];
}

-(void)deleteFriendWithJid:(NSString *)jid{
    XMPPJID *friendJID = [XMPPJID jidWithString:jid];
    [self.xmppRoster removeUser:friendJID];
}

-(void)fetchvCardTempForJid:(NSString *)jid{
    XMPPJID *oneJID = [XMPPJID jidWithString:jid];
    [self.xmppVCardTempModule fetchvCardTempForJID:oneJID ignoreStorage:NO];
}

-(void)updateHeadImage:(id)image{
    NSXMLElement *vCardXML = [NSXMLElement elementWithName:@"vCard" stringValue:@"vcard-temp"];
    NSXMLElement *photoXML = [NSXMLElement elementWithName:@"PHOTO"];
    NSXMLElement *typeXML = [NSXMLElement elementWithName:@"TYPE" stringValue:@"image/jpeg"];
    
    NSData *dataFromImage = UIImageJPEGRepresentation(image, 0.7f);
    
    NSXMLElement *binvalXML = [NSXMLElement elementWithName:@"BINVAL" stringValue:[ZGYBase64Encode base64StrFromData:dataFromImage]];
    [vCardXML addChild:typeXML];
    [vCardXML addChild:binvalXML];
    [vCardXML addChild:photoXML];
    
    
    XMPPvCardTemp * myvCardTemp = [self.xmppVCardTempModule myvCardTemp];
    NSLog(@"%@",myvCardTemp);
    
    
    if (myvCardTemp)
    {
        myvCardTemp.photo = dataFromImage;
        [self.xmppVCardTempModule updateMyvCardTemp:myvCardTemp];
    }else
    {
        XMPPvCardTemp *newvCardTemp = [XMPPvCardTemp vCardTempFromElement:vCardXML];
        newvCardTemp.nickname = @"nick";
        [self.xmppVCardTempModule updateMyvCardTemp:newvCardTemp];
        
    }
    
    
}

#pragma mark - 进行连接服务器操作 -
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
}
//注册成功之后的代理方法
-(void)xmppStreamDidRegister:(XMPPStream *)sender
{
    [self.xmppRoster activate:self.xmmpStream];
    [self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [self.xmppVCardTempModule activate:self.xmmpStream];
    [self.xmppVCardAvatarModule activate:self.xmmpStream];
    NSLog(@"注册成功");
    if (self.callBack) {
        self.callBack(YES,nil);
    }
    
}
//注册失败后的代理方法
-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{
    NSLog(@"注册失败:%@",error);
    if (self.callBack) {
        NSError *myError = [NSError errorWithDomain:error.description code:1000 userInfo:nil];
        self.callBack(NO,myError);
    }
}
//认证成功后调用的代理方法
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    [self.xmppRoster activate:self.xmmpStream];
    [self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [self.xmppVCardTempModule activate:self.xmmpStream];
    [self.xmppVCardAvatarModule activate:self.xmmpStream];
    
    if (self.callBack) {
        self.callBack(YES,nil);
    }
    //获取好友列表
    [self getAllMyFriends];
    //上线
    [self onLine];
    
    NSLog(@"%@",[self.xmppVCardTempModule myvCardTemp].photo);
    
//    [self updateHeadImage:[UIImage imageNamed:@"defaultHead"]];
}
//认证失败调用的代理方法
-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    if (self.callBack) {
        NSError *myError = [NSError errorWithDomain:error.description code:1000 userInfo:nil];
        self.callBack(NO,myError);
    }
}
//<iq to='juliet@example.com/balcony' type='result' id='roster_1'>
//<query xmlns='jabber:iq:roster'>
//<item jid='romeo@example.net'
//name='Romeo'
//subscription='both'>
//<group>Friends</group>
//</item>
//<item jid='mercutio@example.org'
//name='Mercutio'
//subscription='from'>
//<group>Friends</group>
//</item>
//<item jid='benvolio@example.org'
//name='Benvolio'
//subscription='both'>
//<group>Friends</group>
//</item>
//</query>
//</iq>

//subscription
//所谓出席信息就是上线信息
//to" -- 我订阅了他的出席信息, 但是这个联系人没有订阅用户的出席信息
//"from" -- 他订阅了我的出席信息，我没有订阅他的出席信息
//"both" -- 用户和联系人互相订阅了对方的出席信息
-(BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    if([iq.type isEqualToString:@"result"])
    {
        //移除掉所有之前好友记录
        [_userFriendsArr removeAllObjects];
        
        //找到query节点
        NSXMLElement *query = iq.childElement;
        //找到query的子结点，item列表
        NSArray *itemArray = query.children;
        for (NSXMLElement *item in itemArray) {
            NSString *jid = [item attributeStringValueForName:@"jid"];
            NSString *name = [item attributeStringValueForName:@"name"];
            NSString *status = @"unavailable";
            
            FriendModel *friend = [[FriendModel alloc]init];
            friend.jid    = jid;
            friend.name   = name;
            friend.status = status;
            
            [_userFriendsArr addObject:friend];
        }
    }
    NSLog(@"%@",_userFriendsArr);
    //使用通知的方式告诉外面数据到来
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_FRIEND_LIST object:_userFriendsArr];
    return YES;
}

//当自己上线后，服务器会把你好由的上线信息发送给你
//每个好友发送一次，该函数会被调用多次
//当好友上线或下线的时候，该函数也会被调用

// <presence from='juliet@example.com/balcony' type='available'/>
-(void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    //出现类型
    NSString *presenceType = [presence type];
    NSLog(@"出现类型:%@",presenceType);
    //得到用户的jid
    NSString *fromJid = [[presence from] bare];
    NSLog(@"%@",fromJid);
    if(![fromJid containsString:self.userName])
    {
        //type：available 可与之进行通讯
        //      unavailable 不能与之通讯
        NSString *type = presence.type;
        if ([type isEqualToString:@"subscribed"]) {
            FriendModel *friend = [[FriendModel alloc]init];
            friend.jid    = fromJid;
            friend.name   = fromJid;
            friend.status = presence.status;
            
            [_userFriendsArr addObject:friend];
            [[NSNotificationCenter defaultCenter]postNotificationName:UPDATE_FRIEND_LIST object:_userFriendsArr];
            return;
        }
        BOOL FIND=NO;
        for (FriendModel *user in _userFriendsArr) {
            if ([user.jid isEqualToString:fromJid]) {
                user.status = type;
                FIND=YES;
                break;
            }
        }
        if (!FIND) {
            FriendModel *friend = [[FriendModel alloc]init];
            friend.jid    = fromJid;
            friend.name   = fromJid;
            friend.status = presence.status;
            
            [_userFriendsArr addObject:friend];
            [[NSNotificationCenter defaultCenter]postNotificationName:UPDATE_FRIEND_LIST object:_userFriendsArr];
        }
        //发送通知更新好友状态
        [[NSNotificationCenter defaultCenter]postNotificationName:UPDATE_FRIEND_LIST object:_userFriendsArr];
    }
}

//收到好友的聊天消息
-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSString *fromJid = message.from.bare;
    NSString *toJid   = message.to.bare;
    NSString * amessage = message.body;
    if (amessage != nil) {
        MessageModel *model = [[MessageModel alloc]init];
        model.fromJid = fromJid;
        model.toJid   = toJid;
        model.message = amessage;
        
        //发送接受到消息的通知
        [[NSNotificationCenter defaultCenter]postNotificationName:RECEIVE_MESSAGE object:model];
    }
}

#pragma mark - XMPPRoster代理方法 -

- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    //取得好友状态
    NSString *presenceType = [presence type]; //online/offline
    //请求的用户
    NSString *presenceFromUser = [[presence from] user];
    NSLog(@"presenceType:%@",presenceType);
    
    NSLog(@"presence2:%@  sender2:%@",presence,sender);
    //弹出提示，看用户是否同意添加好友
    UIAlertController * alertC=[UIAlertController alertControllerWithTitle:@"添加好友请求" message:[NSString stringWithFormat:@"这孩子请求添加您为好友：%@",presenceFromUser] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * agreeBtn=[UIAlertAction actionWithTitle:@"同意" style:UIAlertActionStyleDefault handler:^(UIAlertAction *  action) {
        XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",presenceFromUser,self.doMainName]];
        [self.xmppRoster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
    }];
    UIAlertAction * rejectBtn=[UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *  action) {
        XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",presenceFromUser,self.doMainName]];
        [self.xmppRoster rejectPresenceSubscriptionRequestFrom:jid];
    }];
    [alertC addAction:agreeBtn];
    [alertC addAction:rejectBtn];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertC animated:YES completion:nil];
    
}

#pragma mark - xmppvCardTempModule的代理方法 -

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule
        didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp
                     forJID:(XMPPJID *)jid{
    NSLog(@"didReceivevCardTemp－》%@ －》%@ －》%@",vCardTempModule,vCardTemp,jid);
}

- (void)xmppvCardTempModuleDidUpdateMyvCard:(XMPPvCardTempModule *)vCardTempModule{
    NSLog(@"xmppvCardTempModuleDidUpdateMyvCard");
}

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule failedToUpdateMyvCard:(NSXMLElement *)error{
    NSLog(@"failedToUpdateMyvCard:->%@",error);
}

-(void)xmppvCardAvatarModule:(XMPPvCardAvatarModule *)vCardTempModule didReceivePhoto:(UIImage *)photo forJID:(XMPPJID *)jid{
    NSLog(@"didReceivePhoto－》%@ －》%@",photo,jid);
    [[NSNotificationCenter defaultCenter]postNotificationName:DID_RECEIVE_VCARD object:nil userInfo:@{jid.user:photo}];
}

#pragma mark - 功能协助方法 -
//<presence/>发送在线消息给服务器
-(void)onLine
{
    //XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    //发送presence节到服务端
    XMPPPresence *presence = [XMPPPresence presence];
    [self.xmmpStream sendElement:presence];
}
//获取好友列表
//发送iq节到服务端，请求好友列表
//roster 花名册，也就是好友列表
//<iq from='juliet@example.com/balcony' type='get' id='roster_1'>
//<query xmlns='jabber:iq:roster'/>
//</iq>
-(void)getAllMyFriends
{
    //组装iq节，也就是按照协议格式拼接成一个xml
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get"];
    [iq addAttributeWithName:@"from" stringValue:self.userName];
    [iq addAttributeWithName:@"id" stringValue:@"12345"];
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
    [iq addChild:query];
    //使用xmppStream发送iq节到服务器
    [self.xmmpStream sendElement:iq];
}



@end
