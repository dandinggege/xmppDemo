//
//  MyMusicPlayer.h
//  MyXmppDemo
//
//  Created by 张广洋 on 15/12/5.
//  Copyright © 2015年 张广洋. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyMusicPlayer : NSObject

+(instancetype)player;

-(void)playWindBgSound;

-(void)playWater0;

-(void)playWater1;

-(void)stop;

@end
