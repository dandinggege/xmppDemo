//
//  MySecurity.m
//  MyXmppDemo
//
//  Created by 张广洋 on 15/11/28.
//  Copyright © 2015年 张广洋. All rights reserved.
//

#import "MySecurity.h"

#import "NSData+AES128.h"

#import "ZGYBase64Encode.h"

@implementation MySecurity

+(NSString *)base64StrFromStr:(NSString *)theStr{
    NSData * decryptData=[theStr dataUsingEncoding:NSUTF8StringEncoding];
    NSData * encryptData=[decryptData AES128EncryptWithKey:@"yang" iv:@"good"];
    return [ZGYBase64Encode base64StrFromData:encryptData];
}

+(NSString *)strFromBase64Str:(NSString *)base64Str{
    NSData * encryptData=[ZGYBase64Encode dataFromBase64Str:base64Str];
    NSData * decryptData=[encryptData AES128DecryptWithKey:@"yang" iv:@"good"];
    return [[NSString alloc]initWithData:decryptData encoding:NSUTF8StringEncoding];
}

@end
