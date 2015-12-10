//
//  UIView+autoLayout.h
//  自定义的自动布局约束
//
//  Created by 张广洋 on 15/10/17.
//  Copyright © 2015年 张广洋. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (autoLayout)


#pragma mark - 父视图上下左右边距 -

//距离父视图左边边距
@property (nonatomic,assign) CGFloat leading;

//距离父视图上边边距
@property (nonatomic,assign) CGFloat top;

//距离父视图右边边距
@property (nonatomic,assign) CGFloat trailing;

//距离父视图下边边距
@property (nonatomic,assign) CGFloat bottom;


#pragma mark - 自身宽度，高度，和宽高比 -

//自身的宽度和高度的比例
@property (nonatomic,assign) CGFloat widthHeightAspactRatio;

//自身的宽度
@property (nonatomic,assign) CGFloat width;

//自身的高度
@property (nonatomic,assign) CGFloat height;


#pragma mark - 和另外一个视图的约束，位置和对齐 -

//与某个视图的左边距
-(void)leading:(CGFloat)constant withView:(UIView *)view;

//与某个视图的上边距
-(void)top:(CGFloat)constant withView:(UIView *)view;

//与某个视图的后边距
-(void)trailing:(CGFloat)constant withView:(UIView *)view;

//与某个视图的下边距
-(void)bottom:(CGFloat)constant withView:(UIView *)view;

//与某个视图的左侧距离（此时视图在view右侧，左边距，当然是水平方向了）
-(void)leftSpace:(CGFloat)constant toView:(UIView *)view;

//与某个视图的右侧距离（此时视图在view左侧）
-(void)rightSpace:(CGFloat)constant toView:(UIView *)view;

//与某个视图的上侧距离（此时视图在view下面）
-(void)topSpace:(CGFloat)constant toView:(UIView *)view;

//与某个视图的下侧距离（此时视图在view上面）
-(void)bottomSpace:(CGFloat)constant toView:(UIView *)view;


#pragma mark - 和另外一个视图的约束，宽度／高度比例 -

//与某个视图宽度的比例
-(void)widthRate:(CGFloat)multiplier fromView:(UIView *)view;

//与某个视图宽度相等
@property (nonatomic,assign) UIView * widthEqualView;

//与某个视图的高度比例
-(void)heightRate:(CGFloat)multiplier formView:(UIView *)view;

//与某个视图高度相等
@property (nonatomic,assign) UIView * heightEqualView;


#pragma mark - 和某个视图上下左右边界对齐 -

//与某个视图左边对齐
@property (nonatomic,assign) UIView * alignLeadingView;

//与某个视图右边对齐
@property (nonatomic,assign) UIView * alignTrailingView;

//与某个视图顶部对齐
@property (nonatomic,assign) UIView * alignTopView;

//与某个视图底部对齐
@property (nonatomic,assign) UIView * alignBottomView;



@end
