//
//  ZGYBase64Encode.h
//  iOS_AES128加解密
//
//  Created by 张广洋 on 15/10/15.
//  Copyright © 2015年 张广洋. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZGYBase64Encode : NSObject

//nsdata转换成base64编码字符串
+(NSString *)base64StrFromData:(NSData *)data;

//把base64编码的字符串转换成nsdata
+(NSData *)dataFromBase64Str:(NSString *)base64Str;

@end
