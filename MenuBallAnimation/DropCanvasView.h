//
//  DropCanvasView.h
//  DropAnimation
//
//  Created by apple on 16/2/18.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

static CGFloat normalThreshold = 170 / 80.0 * 50;
static CGFloat reduceThreshold = 140 / 80.0 * 50;

@interface DropCanvasView : UIView

@property (strong, nonatomic) NSMutableArray    *assisArray;

@property (strong, nonatomic) UIButton  *bottom_Btn;
@property (strong, nonatomic) UIButton  *Menu1_Btn;
@property (strong, nonatomic) UIButton  *Menu2_Btn;
@property (strong, nonatomic) UIButton  *Menu3_Btn;
@property (strong, nonatomic) UIButton  *Menu4_Btn;
@property (strong, nonatomic) UIButton  *MenuCenter_Btn;

@end
