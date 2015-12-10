//
//  NSData+AES128.h
//  iOS_AES128加解密
//
//  Created by 张广洋 on 15/10/15.
//  Copyright © 2015年 张广洋. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AES128)

//加密，kev和iv最多16位
- (NSData *)AES128EncryptWithKey:(NSString *)key iv:(NSString *)iv;

//解密
- (NSData *)AES128DecryptWithKey:(NSString *)key iv:(NSString *)iv;

@end
