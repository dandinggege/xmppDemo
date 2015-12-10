//
//  UIView+autoLayout.m
//  自定义的自动布局约束
//
//  Created by 张广洋 on 15/10/17.
//  Copyright © 2015年 张广洋. All rights reserved.
//


//每个视图的约束id，必需用视图的地址区分开，防止父视图查找约束时候，紊乱。
#define FLAG_STR(f) ([NSString stringWithFormat:@"%@_%p_%p",f,self,self.superview])
#define FLAG_STR_(f,o) ([NSString stringWithFormat:@"%@_%p_%p",f,self,o])



#import "UIView+autoLayout.h"

@implementation UIView (autoLayout)


@dynamic leading;

@dynamic top;

@dynamic trailing;

@dynamic bottom;

@dynamic width;

@dynamic height;

@dynamic widthHeightAspactRatio;

@dynamic widthEqualView;

@dynamic heightEqualView;

@dynamic alignLeadingView;

@dynamic alignTopView;

@dynamic alignTrailingView;

@dynamic alignBottomView;


#pragma mark - 一些必要的方法 -

//获取指定id对应的约束。
static NSLayoutConstraint * constraintWithId(UIView * view,NSString * identifier){
    for(NSLayoutConstraint * constraint in view.superview.constraints){
        if([constraint.identifier isEqualToString:identifier])
            return constraint;
    }
    return nil;
}

//更新性质的约束添加。
static void add_Constraint_with_other_View(UIView * view,NSLayoutAttribute attribute,NSLayoutRelation relation,UIView * view1,NSLayoutAttribute attribute1,float multiplier,float constant,NSString * identifier){
    //判断另外的视图是否存在，否则无法添加约束
    if(view1==nil){
        NSLog(@"《%@》另外视图不存在，无法添加约束！",view1);
        return;
    }
    //不允许自动适应转换成约束！
    if (view.translatesAutoresizingMaskIntoConstraints)
        view.translatesAutoresizingMaskIntoConstraints=NO;
    //看看是否已经添加过对应的约束，有的话，直接修改constant值。
    NSLayoutConstraint * oneCanstraint=constraintWithId(view,identifier);
    if (!(oneCanstraint &&
          (oneCanstraint.firstItem==view) &&
          (oneCanstraint.secondItem==view1))) {
        //添加一个leading的约束给父视图
        NSLayoutConstraint * oneConstraint=[NSLayoutConstraint constraintWithItem:view attribute:attribute relatedBy:relation toItem:view1 attribute:attribute1 multiplier:multiplier constant:constant];
        oneConstraint.identifier=identifier;
        [view.superview addConstraint:oneConstraint];
    }else
        oneCanstraint.constant=constant;
}

//修改与另外一个视图的宽度／高度比例
static void add_Constraint_multiplier_with_otherView(UIView * view,NSLayoutAttribute attribute,NSLayoutRelation relation,UIView * view1,NSLayoutAttribute attribute1,float multiplier,float constant,NSString * identifier){
    //判断另外的视图是否存在，否则无法添加约束
    if(view1==nil){
        NSLog(@"《%@》另外视图不存在，无法添加约束！",view1);
        return;
    }
    //不允许自动适应转换成约束！
    if (view.translatesAutoresizingMaskIntoConstraints)
        view.translatesAutoresizingMaskIntoConstraints=NO;
    //看看是否已经添加过对应的约束，有的话，直接移除该约束，添加新的约束，因为multiplier是只读的。
    NSLayoutConstraint * oneCanstraint=constraintWithId(view,identifier);
    if (oneCanstraint &&
          (oneCanstraint.firstItem==view) &&
          (oneCanstraint.secondItem==view1)) {
        [view.superview removeConstraint:oneCanstraint];
    }
    //添加一个leading的约束给父视图
    NSLayoutConstraint * oneConstraint=[NSLayoutConstraint constraintWithItem:view attribute:attribute relatedBy:relation toItem:view1 attribute:attribute1 multiplier:multiplier constant:constant];
    oneConstraint.identifier=identifier;
    [view.superview addConstraint:oneConstraint];
}

//添加一个父视图上下左右约束
static void add_Constraint_LRTB(UIView * view, NSLayoutAttribute attribute,float multiplier,float constant,NSString * identifier){
    //判断父视图是否存在，否则无法添加约束
    if(view.superview==nil){
        NSLog(@"《%@》的父视图不存在，无法添加约束！",view);
        return;
    }
    //不允许自动适应转换成约束！
    if (view.translatesAutoresizingMaskIntoConstraints)
        view.translatesAutoresizingMaskIntoConstraints=NO;
    //看看是否已经添加过对应的约束，有的话，直接修改constant值。
    NSLayoutConstraint * oneCanstraint=constraintWithId(view,identifier);
    if (!(oneCanstraint && (oneCanstraint.firstItem==view))) {
        //添加一个leading的约束给父视图
        NSLayoutConstraint * oneConstraint=[NSLayoutConstraint constraintWithItem:view attribute:attribute relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:attribute multiplier:multiplier constant:constant];
        oneConstraint.identifier=identifier;
        [view.superview addConstraint:oneConstraint];
    }else
        oneCanstraint.constant=constant;
}

static void add_Constraint_W_H_Ratio(UIView * view,float multiplier,float constant){
    //判断父视图是否存在，否则无法添加约束
    if(view.superview==nil){
        NSLog(@"《%@》的父视图不存在，无法添加约束！",view);
        return;
    }
    //不允许自动适应转换成约束！
    if (view.translatesAutoresizingMaskIntoConstraints)
        view.translatesAutoresizingMaskIntoConstraints=NO;
    //看看是否已经添加过对应的约束，有的话，直接移除该约束，添加新的约束，因为multiplier是只读的。
    NSLayoutConstraint * oneCanstraint=constraintWithId(view,[NSString stringWithFormat:@"WidthHeightAspactRatio_%p_%p",view,view.superview]);
    //如果有宽高比，先移除，然后再添加
    if (oneCanstraint && (oneCanstraint.firstItem==view)) {
        [view.superview removeConstraint:oneCanstraint];
    }
    //添加一个leading的约束给父视图
    NSLayoutConstraint * oneConstraint=[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeHeight multiplier:multiplier constant:constant];
    oneConstraint.identifier=[NSString stringWithFormat:@"WidthHeightAspactRatio_%p_%p",view,view.superview];
    [view.superview addConstraint:oneConstraint];
}

//设置视图的宽度／高度
static void add_Constraint_W_H(UIView * view,NSLayoutAttribute attribute,float constant,NSString * identifier){
    //不允许自动适应转换成约束！
    if (view.translatesAutoresizingMaskIntoConstraints)
        view.translatesAutoresizingMaskIntoConstraints=NO;
    //看看是否已经添加过对应的约束，有的话，直接修改constant值。
    NSLayoutConstraint * oneCanstraint=constraintWithId(view,identifier);
    if (!(oneCanstraint && (oneCanstraint.firstItem==view))) {
        //添加一个leading的约束给父视图
        NSLayoutConstraint * oneConstraint=[NSLayoutConstraint constraintWithItem:view attribute:attribute relatedBy:NSLayoutRelationEqual toItem:nil attribute:attribute multiplier:1 constant:constant];
        oneConstraint.identifier=identifier;
        [view.superview addConstraint:oneConstraint];
    }else
        oneCanstraint.constant=constant;
}


#pragma mark - 父视图上下左右边距 -

-(void)setLeading:(CGFloat)leading{
    add_Constraint_LRTB(self, NSLayoutAttributeLeading, 1, leading,FLAG_STR(@"leading"));
}

-(CGFloat)leading{
    NSLayoutConstraint * theConstraint=constraintWithId(self, FLAG_STR(@"leading"));
    if (theConstraint)
        return theConstraint.constant;
    return 0;
}

-(void)setTop:(CGFloat)top{
    add_Constraint_LRTB(self, NSLayoutAttributeTop, 1, top,FLAG_STR(@"top"));
}

-(CGFloat)top{
    NSLayoutConstraint * theConstraint=constraintWithId(self, FLAG_STR(@"top"));
    if (theConstraint)
        return theConstraint.constant;
    return 0;
}

-(void)setTrailing:(CGFloat)trailing{
    add_Constraint_LRTB(self, NSLayoutAttributeTrailing, 1, -trailing,FLAG_STR(@"trailing"));
}

-(CGFloat)trailing{
    NSLayoutConstraint * theConstraint=constraintWithId(self, FLAG_STR(@"trailing"));
    if (theConstraint)
        return theConstraint.constant;
    return 0;
}

-(void)setBottom:(CGFloat)bottom{
    add_Constraint_LRTB(self, NSLayoutAttributeBottom, 1, -bottom,FLAG_STR(@"bottom"));
}

-(CGFloat)bottom{
    NSLayoutConstraint * theConstraint=constraintWithId(self, FLAG_STR(@"bottom"));
    if (theConstraint)
        return theConstraint.constant;
    return 0;
}


#pragma mark - 自身宽度，高度，宽高比 -

-(void)setWidthHeightAspactRatio:(CGFloat)WidthHeightAspactRatio{
    add_Constraint_W_H_Ratio(self, WidthHeightAspactRatio, 0);
}

-(CGFloat)widthHeightAspactRatio{
    NSLayoutConstraint * theConstraint=constraintWithId(self, [NSString stringWithFormat:@"WidthHeightAspactRatio_%p_%p",self,self.superview]);
    if (theConstraint)
        return theConstraint.multiplier;
    return 0;
}

-(void)setWidth:(CGFloat)width{
    add_Constraint_W_H(self,NSLayoutAttributeWidth,width,FLAG_STR(@"width"));
}

-(CGFloat)width{
    NSLayoutConstraint * theConstraint=constraintWithId(self, FLAG_STR(@"width"));
    if (theConstraint)
        return theConstraint.constant;
    return 0;
}

-(void)setHeight:(CGFloat)height{
    add_Constraint_W_H(self,NSLayoutAttributeHeight,height,FLAG_STR(@"height"));
}

-(CGFloat)height{
    NSLayoutConstraint * theConstraint=constraintWithId(self, FLAG_STR(@"height"));
    if (theConstraint)
        return theConstraint.constant;
    return 0;
}


#pragma mark - 和其他视图之间的关系 -

-(void)leading:(CGFloat)constant withView:(UIView *)view{
    add_Constraint_with_other_View(self,NSLayoutAttributeLeading,NSLayoutRelationEqual,view,NSLayoutAttributeLeading,1,constant,FLAG_STR_(@"leadingWithView",view));
}

-(void)top:(CGFloat)constant withView:(UIView *)view{
    add_Constraint_with_other_View(self, NSLayoutAttributeTop, NSLayoutRelationEqual, view, NSLayoutAttributeTop, 1, constant, FLAG_STR_(@"topWithView",view));
}

-(void)trailing:(CGFloat)constant withView:(UIView *)view{
    add_Constraint_with_other_View(self, NSLayoutAttributeTrailing, NSLayoutRelationEqual, view, NSLayoutAttributeTrailing, 1, -constant, FLAG_STR_(@"trailingWithView",view));
}

-(void)bottom:(CGFloat)constant withView:(UIView *)view{
    add_Constraint_with_other_View(self, NSLayoutAttributeBottom, NSLayoutRelationEqual, view, NSLayoutAttributeBottom, 1, constant, FLAG_STR_(@"bottomWithView",view));
}


#pragma mark -

-(void)leftSpace:(CGFloat)constant toView:(UIView *)view{
    add_Constraint_with_other_View(self, NSLayoutAttributeLeading, NSLayoutRelationEqual, view, NSLayoutAttributeTrailing, 1, constant, FLAG_STR_(@"leftSpaceToView",view));
}


-(void)rightSpace:(CGFloat)constant toView:(UIView *)view{
    add_Constraint_with_other_View(self, NSLayoutAttributeTrailing, NSLayoutRelationEqual, view, NSLayoutAttributeLeading, 1, -constant, FLAG_STR_(@"rightSpaceToView",view));
}


-(void)topSpace:(CGFloat)constant toView:(UIView *)view{
    add_Constraint_with_other_View(self, NSLayoutAttributeTop, NSLayoutRelationEqual, view, NSLayoutAttributeBottom, 1, constant, FLAG_STR_(@"topSpaceToView",view));
}

-(void)bottomSpace:(CGFloat)constant toView:(UIView *)view{
    add_Constraint_with_other_View(self, NSLayoutAttributeBottom, NSLayoutRelationEqual, view, NSLayoutAttributeTop, 1, -constant, FLAG_STR_(@"bottomSpaceToView",view));
}


#pragma mark - 与某个视图，上下左右对齐 -

-(void)setAlignLeadingView:(UIView *)alignLeadingView{
    [self leading:0 withView:alignLeadingView];
}

-(UIView *)alignLeadingView{
    return nil;
}

-(void)setAlignTrailingView:(UIView *)alignTrailingView{
    [self trailing:0 withView:alignTrailingView];
}

-(UIView *)alignTrailingView{
    return nil;
}

-(void)setAlignTopView:(UIView *)alignTopView{
    [self top:0 withView:alignTopView];
}

-(UIView *)alignTopView{
    return nil;
}

-(void)setAlignBottomView:(UIView *)alignBottomView{
    [self bottom:0 withView:alignBottomView];
}

-(UIView *)alignBottomView{
    return nil;
}


#pragma mark - 与另外一个视图的宽／高比 -

-(void)widthRate:(CGFloat)multiplier fromView:(UIView *)view{
    add_Constraint_multiplier_with_otherView(self, NSLayoutAttributeWidth, NSLayoutRelationEqual, view, NSLayoutAttributeWidth, multiplier, 0, FLAG_STR_(@"widthRateWithView",view));
}

-(void)heightRate:(CGFloat)multiplier formView:(UIView *)view{
    add_Constraint_multiplier_with_otherView(self, NSLayoutAttributeHeight, NSLayoutRelationEqual, view, NSLayoutAttributeHeight, multiplier, 0, FLAG_STR_(@"heightRateWithView",view));
}

-(void)setWidthEqualView:(UIView *)widthEqualView{
    [self widthRate:1 fromView:widthEqualView];
}

-(void)setHeightEqualView:(UIView *)heightEqualView{
    [self heightRate:1 formView:heightEqualView];
}

@end
