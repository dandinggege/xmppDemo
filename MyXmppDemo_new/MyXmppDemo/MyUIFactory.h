//
//  MyUIFactory.h
//  MyXmppDemo
//
//  Created by 张广洋 on 15/12/5.
//  Copyright © 2015年 张广洋. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface MyUIFactory : NSObject

//显示一句提示框
+(void)showMsg:(NSString *)msg withVC:(UIViewController *)vc;

//剪切图片的方法哦！
+(UIImage *)scaleImage:(UIImage *)img toSize:(CGSize)size;

@end
