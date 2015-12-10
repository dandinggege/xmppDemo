//
//  FriendModel.h
//  
//
//  Created by 张广洋 on 15/11/15.
//
//

#import <Foundation/Foundation.h>

@interface FriendModel : NSObject

//用户id
@property (nonatomic,copy) NSString * jid;
//用户名称
@property (nonatomic,copy) NSString * name;
//用户状态
//unavailable  用户不可通信，发消息收不到
//availabel    可以与之通信
@property (nonatomic,copy) NSString * status;

@end
