//
//  MyUIFactory.m
//  MyXmppDemo
//
//  Created by 张广洋 on 15/12/5.
//  Copyright © 2015年 张广洋. All rights reserved.
//

#import "MyUIFactory.h"

@implementation MyUIFactory

+(void)showMsg:(NSString *)msg withVC:(UIViewController *)vc{
    UIAlertController * alertC=[UIAlertController alertControllerWithTitle:@"嘿嘿嘿" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * sureBtn=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
    }];
    [alertC addAction:sureBtn];
    [vc presentViewController:alertC animated:YES completion:^{
        
    }];
}

+(UIImage *)scaleImage:(UIImage *)img toSize:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0,0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    //返回新的改变大小后的图片
    return scaledImage;
}

@end
