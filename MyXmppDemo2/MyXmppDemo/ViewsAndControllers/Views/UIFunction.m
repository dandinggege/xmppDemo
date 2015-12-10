//
//  UIFunction.m
//  
//
//  Created by 张广洋 on 15/11/15.
//
//

#import "UIFunction.h"

@implementation UIFunction

+(void)showAlertWithTitle:(NSString *)title Message:(NSString *)message viewController:(UIViewController *)viewController{
    UIAlertController * alertVC=[UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * action=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:action];
    [viewController presentViewController:alertVC animated:YES completion:nil];
}

@end
