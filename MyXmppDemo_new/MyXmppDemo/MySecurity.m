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

#import <CommonCrypto/CommonCrypto.h>

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

#pragma mark - 进行md5加密
+(NSString *)getMD5StrFromString:(NSString *)beforeMD5String
{
    const char * cString = [beforeMD5String UTF8String];
    unsigned char result[16];
    CC_MD5(cString, (CC_LONG)strlen((const char *)cString), result);
    NSString *sign= [NSString stringWithFormat:
                     @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                     result[0], result[1], result[2], result[3],
                     result[4], result[5], result[6], result[7],
                     result[8], result[9], result[10], result[11],
                     result[12], result[13], result[14], result[15]
                     ];
    return [sign uppercaseString];
}

@end
