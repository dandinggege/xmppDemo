//
//  MySecurity.h
//  MyXmppDemo
//
//  Created by 张广洋 on 15/11/28.
//  Copyright © 2015年 张广洋. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ZGY_MD5(str) ([MySecurity getMD5StrFromString:str])

@interface MySecurity : NSObject

+(NSString *)base64StrFromStr:(NSString *)theStr;

+(NSString *)strFromBase64Str:(NSString *)base64Str;

+(NSString *)getMD5StrFromString:(NSString *)beforeMD5String;

@end
