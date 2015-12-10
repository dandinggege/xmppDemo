//
//  NSData+AES128.m
//  iOS_AES128加解密
//
//  Created by 张广洋 on 15/10/15.
//  Copyright © 2015年 张广洋. All rights reserved.
//

#import "NSData+AES128.h"

#import <CommonCrypto/CommonCrypto.h>

@implementation NSData (AES128)

- (NSData *)AES128EncryptWithKey:(NSString *)key iv:(NSString *)iv
{
    return [self AES128Operation:kCCEncrypt key:key iv:iv];
}

- (NSData *)AES128DecryptWithKey:(NSString *)key iv:(NSString *)iv
{
    return [self AES128Operation:kCCDecrypt key:key iv:iv];
}

- (NSData *)AES128Operation:(CCOperation)operation key:(NSString *)key iv:(NSString *)iv
{
    //一个char数组，kCCKeySizeAES128 ＝ 16
    char keyPtr[kCCKeySizeAES128 + 1];
    //把数组全部设置为0，
    memset(keyPtr, 0, sizeof(keyPtr));
    //把NSString存放到字符数组里面，字符数组最多是16位
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    //创建一个字符数组，kCCBlockSizeAES128 ＝ 16
    char ivPtr[kCCBlockSizeAES128 + 1];
    //把字符数组全部值为 0
    memset(ivPtr, 0, sizeof(ivPtr));
    //把NSString 放进字符数组里面，最多16位 17位的话，最后一个不晓得要不要存放"\0"
    [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    //取出要加密的数据的长度
    NSUInteger dataLength = [self length];
    //把该长度加上 kCCBlockSizeAES128 ＝ 16
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    //从内存中开辟一个bufferSize大小的空间，指针给buffer （void *） 任意类型
    void * buffer = malloc(bufferSize);
    
    //numBytesCrypted 接收加密解密后的数据的长度
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          kCCBlockSizeAES128,
//                                          kCCKeySizeAES256,
//                                          kCCKeySize3DES,
                                          ivPtr,
                                          [self bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    if (cryptStatus == kCCSuccess)
    {
        //注意，此时的buffer是一个局部变量
        NSData * cryptData=[NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
        //这里的buffer没有free哦
        return cryptData;
    }
    //buffer是malloc出来的，要释放掉
    free(buffer);
    return nil;
}

@end
