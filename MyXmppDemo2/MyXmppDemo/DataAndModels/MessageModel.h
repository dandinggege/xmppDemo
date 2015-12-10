//
//  MessageModel.h
//  
//
//  Created by 张广洋 on 15/11/15.
//
//

#import <Foundation/Foundation.h>

@interface MessageModel : NSObject

//发送方
@property (nonatomic,copy) NSString * fromJid;
//接收方
@property (nonatomic,copy) NSString * toJid;
//消息内容
@property (nonatomic,copy) NSString * message;

@end
