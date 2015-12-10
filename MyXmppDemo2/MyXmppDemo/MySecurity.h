//
//  MySecurity.h
//  MyXmppDemo
//
//  Created by 张广洋 on 15/11/28.
//  Copyright © 2015年 张广洋. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MySecurity : NSObject

+(NSString *)base64StrFromStr:(NSString *)theStr;

+(NSString *)strFromBase64Str:(NSString *)base64Str;

@end
