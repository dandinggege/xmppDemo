//
//  MyMusicPlayer.m
//  MyXmppDemo
//
//  Created by 张广洋 on 15/12/5.
//  Copyright © 2015年 张广洋. All rights reserved.
//

#import "MyMusicPlayer.h"

#import <AVFoundation/AVFoundation.h>

@interface MyMusicPlayer()
<AVAudioPlayerDelegate>
{
    AVAudioPlayer * _bgAudioPlayer;
    AVAudioPlayer * _soundEffectAudioPlayer;
}

@end

@implementation MyMusicPlayer

+(instancetype)player{
    static MyMusicPlayer * _player=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _player=[[MyMusicPlayer alloc]init];
    });
    return _player;
}

-(void)playWindBgSound{
    [self playBackgroundSoundWithReSource:@"slowWind" type:@"mp3" loopNum:-1];
}

-(void)playWater0{
    [self playSoundEffectWithReSource:@"water0" type:@"MP3"];
}

-(void)playWater1{
    [self playSoundEffectWithReSource:@"water1" type:@"wav"];
}

-(void)playBackgroundSoundWithReSource:(NSString *)soundResource type:(NSString *)type loopNum:(NSInteger)ln{
    if ([_bgAudioPlayer isPlaying]) {
        [self stop];
    }
    //获取音频文件沙盒路径
    NSString * audioFilePath=[[NSBundle mainBundle]pathForResource:soundResource ofType:type];
    //转换成url
    NSURL * audioURL=[NSURL fileURLWithPath:audioFilePath];
    //实例化播放器
    _bgAudioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:audioURL error:nil];
    _bgAudioPlayer.volume=0.5;
    _bgAudioPlayer.numberOfLoops=ln;
    _bgAudioPlayer.delegate=self;
    //准备播放
    [_bgAudioPlayer prepareToPlay];
    [_bgAudioPlayer play];
}

-(void)playSoundEffectWithReSource:(NSString *)soundResource type:(NSString *)type{
    if ([_soundEffectAudioPlayer isPlaying]) {
        [_soundEffectAudioPlayer stop];
        _soundEffectAudioPlayer=nil;
    }
    //获取音频文件沙盒路径
    NSString * audioFilePath=[[NSBundle mainBundle]pathForResource:soundResource ofType:type];
    //转换成url
    NSURL * audioURL=[NSURL fileURLWithPath:audioFilePath];
    //实例化播放器
    _soundEffectAudioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:audioURL error:nil];
    _soundEffectAudioPlayer.volume=0.5;
    _soundEffectAudioPlayer.numberOfLoops=0;
    _soundEffectAudioPlayer.delegate=self;
    //准备播放
    [_soundEffectAudioPlayer prepareToPlay];
    [_soundEffectAudioPlayer play];
}

-(void)stop{
    if ([_bgAudioPlayer isPlaying]) {
        [_bgAudioPlayer stop];
        _bgAudioPlayer=nil;
    }
}


#pragma mark - audioPlayer代理方法 -

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    player=nil;
}

@end
