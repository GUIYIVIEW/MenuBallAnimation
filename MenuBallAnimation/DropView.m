//
//  DropView.m
//  DropAnimation
//
//  Created by apple on 16/2/17.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "DropView.h"
#import "PointMath.h"



@implementation TwoLineClass

- (instancetype)initWithTwoLineMath_line1:(LineMath *)line1 line2:(LineMath *)line2
{
    self = [super init];
    if (!self) {
        self = nil;
    }
    
    _lineMath1 = line1;
    _lineMath2 = line2;
    
    return self;
}

@end





@interface DropView()

@end



@implementation DropView

- (instancetype)initWithFrame:(CGRect)frame createSmallDrop:(BOOL)createSmallDrop
{
    self = [super initWithFrame:frame];
    if (!self) {
        self = nil;
    }
    
    [self createDropView];
    
    if (createSmallDrop == YES) {
        [self createSmallDropView];
        [self createPanGesture];
    }
    
    return self;
}

- (void)createDropView
{
    self.backgroundColor = [UIColor clearColor];//[[UIColor orangeColor] colorWithAlphaComponent:0.5];
    self.layer.cornerRadius = self.width/2;
    self.layer.masksToBounds = NO;
    self.clipsToBounds = NO;
    
    _mainCenter = CGPointMake(self.width/2.0f, self.height/2.0f);
    _circleMath = [[CircleMath alloc] initWithCenterPoint:CGPointMake(self.width/2, self.height/2) radius:self.width/2 inView:self];
    
    _bezierPath = [UIBezierPath bezierPath];
    
    _assisDropArray = [[NSMutableArray alloc] init];
    
    _dropShapLayer = [CAShapeLayer layer];
//    _dropShapLayer.lineWidth = 2.0f;
//    _dropShapLayer.strokeColor = [[UIColor blackColor] colorWithAlphaComponent:0.7].CGColor;
    _dropShapLayer.strokeStart = 0;
    _dropShapLayer.strokeEnd = 1;
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(calucateCoordinate1)];
//    _displayLink.frameInterval = 20;
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
//    _displayLink.paused = YES;
}

- (void)createSmallDropView
{
    for (int i = 0; i < 4; i++) {
        
        CGFloat assisDrop_width = self.width;
        
        DropView *assisDrop = [[DropView alloc] initWithFrame:CGRectMake(0, 0, assisDrop_width, assisDrop_width) createSmallDrop:NO];
        [self initSetAssisDrop:assisDrop];
        
        [_assisDropArray addObject:assisDrop];
    }
}

- (void)initSetAssisDrop:(DropView *)assisDrop
{
    CGFloat assisDrop_width = self.width;
    
//    assisDrop.backgroundColor = [UIColor orangeColor];
    assisDrop.layer.cornerRadius = assisDrop_width/2;
    assisDrop.fillColor = _fillColor;
    
    [self addSubview:assisDrop];
    [assisDrop BearSetCenterToParentViewWithAxis:kAXIS_X_Y];
}

- (void)createPanGesture
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture_Event:)];
    [self addGestureRecognizer:panGesture];
}

- (void)panGesture_Event:(UIPanGestureRecognizer *)panGesture
{
    if (panGesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint tempPoint = [panGesture locationInView:self];
        
        CGFloat centerX = self.width/2;
        CGFloat centerY = self.height/2;
        CGFloat deltaX = abs((int)centerX - (int)tempPoint.x);
        
//        _assisDrop1.center = CGPointMake(centerX - deltaX, centerY - deltaX);
//        _assisDrop2.center = CGPointMake(centerX + deltaX, centerY - deltaX);
//        _assisDrop3.center = CGPointMake(centerX + deltaX, centerY + deltaX);
//        _assisDrop4.center = CGPointMake(centerX - deltaX, centerY + deltaX);
        
        [self calucateCoordinate1];
    }
    else if(panGesture.state == UIGestureRecognizerStateEnded){
        
//        [UIView animateWithDuration:20.0
//                              delay:0
//             usingSpringWithDamping:0.3
//              initialSpringVelocity:0
//                            options:UIViewAnimationOptionCurveEaseInOut
//                         animations:^{
//                             [self assisDropHidden];
////                             [_smallDrop BearSetCenterToParentViewWithAxis:kAXIS_X_Y];
////                             _displayLink.paused = NO;
//                         }
//                         completion:^(BOOL finished) {
//                             _displayLink.paused = YES;
//                         }];
    }
}

//  新的计算坐标的方法
- (void)calucateCoordinate1
{
    [_dropSuperView.assisArray removeAllObjects];

    DropView *tempAssisDrop0;
    DropView *tempAssisDrop1;
    if ([_assisDropArray count] > 1) {
        tempAssisDrop0 = _assisDropArray[0];
        tempAssisDrop1 = _assisDropArray[1];
    }
    
    if (!tempAssisDrop0 || !tempAssisDrop1) {
        return;
    }
    
    CGFloat radius_SmallAddMain = self.circleMath.radius + tempAssisDrop0.circleMath.radius;
    CGFloat radius_SmallAddSmall = tempAssisDrop0.circleMath.radius + tempAssisDrop1.circleMath.radius;
    
    CALayer *assisDrop1_PreLayer = tempAssisDrop0.layer.presentationLayer;
    CALayer *assisDrop2_PreLayer = tempAssisDrop1.layer.presentationLayer;
    
    CGFloat dis_SmallToMain = [LineMath calucateDistanceBetweenPoint1:assisDrop1_PreLayer.position withPoint2:_mainCenter];
    CGFloat dis_SmallToSmall = [LineMath calucateDistanceBetweenPoint1:assisDrop1_PreLayer.position withPoint2:assisDrop2_PreLayer.position];
    
    //小圆和大圆相离
    if (dis_SmallToMain + faultTolerantValue_SmallToMain >= radius_SmallAddMain) {
//        NSLog(@"小圆和大圆相离");
        _relation = kSeparated_SmallToMain;
        
        for (DropView *assisDropView in _assisDropArray) {
            [self calucateCrossPointDropView1:assisDropView dropView2:self setCondition:kSetNull];
        }
        
    }
    //小圆和大圆相交
    else if (dis_SmallToMain + faultTolerantValue_SmallToMain < radius_SmallAddMain && dis_SmallToSmall + faultTolerantValue_SmallToSmall >= radius_SmallAddSmall){
//        NSLog(@"小圆和大圆相交");
        _relation = kCross_SmallToMain;
        
        for (DropView *assisDropView in _assisDropArray) {
            [self calucateCrossPointDropView1:assisDropView dropView2:self setCondition:kSetNull];
        }
        
    }
    //小圆和小圆相交
    else if (dis_SmallToMain + faultTolerantValue_SmallToMain < radius_SmallAddMain && dis_SmallToSmall + faultTolerantValue_SmallToSmall < radius_SmallAddSmall && abs((int)dis_SmallToMain) > faultTolerantValue_Inintional){
//        NSLog(@"小圆和小圆相交");
        _relation = kCross_SmallToSmall;
        
        for (DropView *assisDropView in _assisDropArray) {
            [self calucateCrossPointDropView1:assisDropView dropView2:self setCondition:kSetNull];
        }
        
        for (int i = 0; i < [_assisDropArray count]; i++) {
            DropView *assisDropView_now = _assisDropArray[i];
            
            DropView *assisDropView_later;
            if (i == [_assisDropArray count] - 1) {
                assisDropView_later = _assisDropArray[0];
            }else{
                assisDropView_later = _assisDropArray[i + 1];
            }
            
            [self calucateCrossPointDropView1:assisDropView_now dropView2:assisDropView_later setCondition:kSetRightPoint];
            [self calucateCrossPointDropView1:assisDropView_later dropView2:assisDropView_now setCondition:kSetLeftPoint];
        }
    }
    //初始位置
    else if (abs((int)dis_SmallToMain) < faultTolerantValue_Inintional){
        _relation = kInitional;
    }else{
//        NSLog(@"都不是");
    }
    
    [_dropSuperView setNeedsDisplay];
}


//  计算圆心连线的垂线与圆的交点1,贝塞尔绘制点两侧（edge_point1_left，edge_point1_right）
- (AcrossPointStruct)calucateEdgePoint_LeftANDRight_WithCircleMath:(CircleMath *)circleMath withOriginLine:(LineMath *)line needPoint1:(BOOL)needPoint1
{
    //  设定一个指定半径的圆，并且求line和该圆的交点acrossPoint
    CGPoint centerPoint;
    centerPoint = [self convertPoint:circleMath.centerPoint fromView:circleMath.InView];
    
    CGFloat deltaRadiusRatio = 0.2;
    CircleMath *tempCircle = [[CircleMath alloc] initWithCenterPoint:centerPoint radius:circleMath.radius * (1 - deltaRadiusRatio) inView:self];
    AcrossPointStruct acrossPointStruct = [self calucateCircleAndLineAcrossPoint_withCircle:tempCircle withLine:line];
    
    CGPoint acrossPoint;
    
    if (needPoint1 == YES) {
        acrossPoint = acrossPointStruct.point1;
    }else{
        acrossPoint = acrossPointStruct.point2;
    }
    
    //  计算经过点acrossPoint并且和line垂直的线perBiseLine
    LineMath *perBiseLine = [[LineMath alloc] init];
    CGFloat angle = atan(line.k);
    angle += M_PI/2;
    if (angle > M_PI/2) {
        angle -= M_PI;
    }else if (angle < - M_PI/2){
        angle += M_PI;
    }
    perBiseLine.k = tan(angle);
    perBiseLine.b = acrossPoint.y - perBiseLine.k * acrossPoint.x;
    
    //  计算perBiseLine和circle的两个交点
    CircleMath *tempCircle1 = [[CircleMath alloc] initWithCenterPoint:centerPoint radius:circleMath.radius inView:self];
    AcrossPointStruct acrossPointStruct1 = [self calucateCircleAndLineAcrossPoint_withCircle:tempCircle1 withLine:perBiseLine];
    
//    LineMath *tempLine11 = [[LineMath alloc] initWithPoint1:acrossPointStruct1.point1 point2:acrossPointStruct1.point2 inView:self];
//    [_dropSuperView.assisArray addObject:tempLine11];
    
    return acrossPointStruct1;
}


#pragma mark - 计算两圆有重叠时的交点
/** 计算两圆有重叠时的交点
 *
 *  r1  小圆半径
 *  r2  大圆半径
 *  x   两圆心的距离
 *  x1  小圆圆心和两圆焦点连线的距离
 *  x2  大圆圆心和两圆焦点连线的距离
 *  x3  两圆连线的线长的一半长度
 *
 *  (x_o,y_o)   两圆圆心连线和两圆焦点连线的交点
 *  verLine     两圆心连线基于点(x_o,y_o)的垂线
 */
- (AcrossPointStruct)calucateCrossPointDropView1:(DropView *)dropView1 dropView2:(DropView *)dropView2 setCondition:(kSetCondition)setCondition
{
    DropView *tempAssisDrop0;
    DropView *tempAssisDrop1;
    if ([_assisDropArray count] > 1) {
        tempAssisDrop0 = _assisDropArray[0];
        tempAssisDrop1 = _assisDropArray[1];
    }
    
    if (!tempAssisDrop0 || !tempAssisDrop1) {
        
        AcrossPointStruct acrossPointstruct;
        return acrossPointstruct;
    }
    
    CGFloat radius_SmallAddMain = self.circleMath.radius + tempAssisDrop0.circleMath.radius;
    CGFloat radius_SmallAddSmall = tempAssisDrop0.circleMath.radius + tempAssisDrop1.circleMath.radius;
    
    CALayer *assisDrop1_PreLayer = tempAssisDrop0.layer.presentationLayer;
    CALayer *assisDrop2_PreLayer = tempAssisDrop1.layer.presentationLayer;
    
    CGFloat dis_SmallToMain = [LineMath calucateDistanceBetweenPoint1:assisDrop1_PreLayer.position withPoint2:_mainCenter];
    CGFloat dis_SmallToSmall = [LineMath calucateDistanceBetweenPoint1:assisDrop1_PreLayer.position withPoint2:assisDrop2_PreLayer.position];
    
    
    
    
    
    CGFloat r1 = dropView1.circleMath.radius;
    CGFloat r2 = dropView2.circleMath.radius;
    
    CALayer *dropView1_PreLayer = dropView1.layer.presentationLayer;
    CALayer *dropView2_PreLayer = dropView2.layer.presentationLayer;
    CGPoint center1 = ![dropView1 isEqual:self] ? dropView1_PreLayer.position : _mainCenter;
    CGPoint center2 = ![dropView2 isEqual:self] ? dropView2_PreLayer.position : _mainCenter;

    
    CGFloat x  = [LineMath calucateDistanceBetweenPoint1:center1 withPoint2:center2];
    CGFloat x1;
    CGFloat x2;
    CGFloat x3;
    __block CGFloat x_o;
    __block CGFloat y_o;
    
    x1 = ( (r1*r1) - (r2*r2) + (x*x)) / (2 * x);
    x2 = x - x1;
    x3 = sqrt((r1*r1) - (x1*x1));
    
    
    //  Center2Centerde的垂线 VerticalLine
    LineMath *verLine = [[LineMath alloc] init];
    verLine.tempCenter = [LineMath calucateCenterPointBetweenPoint1:center1 withPoint2:center2];
    verLine.InView = self;
    
    LineMath *lineCenter2Center = [[LineMath alloc] initWithPoint1:center1 point2:center2 inView:self];
    //    [_dropSuperView.assisArray addObject:lineCenter2Center];
    
    if (_relation != kSeparated_SmallToMain) {
        
        switch (lineCenter2Center.lineStatus) {
            case kLineNormal:
            {
                CGFloat angle = atan(lineCenter2Center.k);
                
                //  x_o角度修正
                [DropView eventInDiffQuadrantWithCenterPoint:center1
                                               withParaPoint:center2
                                               quadrantFirst:^{
                                                   x_o = r1 - cos(angle) * x2;
                                               }
                                              quadrantSecond:^{
                                                  x_o = r1 + cos(angle) * x2;
                                              }
                                               quadrantThird:^{
                                                   x_o = r1 + cos(angle) * x2;
                                               }
                                              quadrantFourth:^{
                                                  x_o = r1 - cos(angle) * x2;
                                              }];
                
                y_o = lineCenter2Center.k * x_o + lineCenter2Center.b;
                
                //  Center2Centerde的垂线 VerticalLine
                angle += M_PI/2;
                if (angle > M_PI/2) {
                    angle -= M_PI;
                }else if (angle < - M_PI/2){
                    angle += M_PI;
                }
                
                verLine.k = tan(angle);
                verLine.b = y_o - verLine.k * x_o;
            }
                break;
                
            case kLineHorizontal:
            {
                verLine.lineStatus = kLineVertical;
            }
                break;
                
            case kLineVertical:
            {
                verLine.lineStatus = kLineHorizontal;
            }
                break;
                
            default:
                break;
        }
    }
    
    //  垂直平分线的两点
    AcrossPointStruct acrossPointStruct = [self calucateCircleAndLineAcrossPoint_withCircle:dropView1.circleMath withLine:verLine];
    verLine.point1 = acrossPointStruct.point1;
    verLine.point2 = acrossPointStruct.point2;
    
    switch (_relation) {
        case kSeparated_SmallToMain:
        {
            [_dropSuperView.assisArray addObject:lineCenter2Center];
            
            
            //  小圆和lineCenter2Center的交点
            AcrossPointStruct small_AcrossPointSrtuct = [self calucateCircleAndLineAcrossPoint_withCircle:dropView1.circleMath withLine:lineCenter2Center];
            dropView1.crossToCenterAssis_Point = [LineMath calucatePointWithOriginPoint:_mainCenter point1:small_AcrossPointSrtuct.point1 point2:small_AcrossPointSrtuct.point2 condition:kNear];
            
            //            //  绘制辅助点，小圆上的
            //            PointMath *pointMath1 = [[PointMath alloc] initWithPoint:dropView1.crossToCenterAssis_Point inView:self];
            //            pointMath1.radius = [NSNumber numberWithFloat:4.0f];
            //            [_dropSuperView.assisArray addObject:pointMath1];
            
            
            
            //  大圆和lineCenter2Center的交点
            AcrossPointStruct main_AcrossPointStruct = [self calucateCircleAndLineAcrossPoint_withCircle:dropView2.circleMath withLine:lineCenter2Center];
            dropView1.crossToCenterAssis_PointMain = [LineMath calucatePointWithOriginPoint:center1 point1:main_AcrossPointStruct.point1 point2:main_AcrossPointStruct.point2 condition:kNear];
            
            //            //  绘制辅助点，大圆上
            //            PointMath *pointMath2 = [[PointMath alloc] initWithPoint:dropView1.crossToCenterAssis_PointMain inView:self];
            //            pointMath2.radius = [NSNumber numberWithFloat:4.0f];
            //            [_dropSuperView.assisArray addObject:pointMath2];
            
            
            //  开始减小
            if (dis_SmallToMain > reduceThreshold && dis_SmallToMain < normalThreshold){
//                NSLog(@"开始减小");
                
                CGFloat ratio = [LineMath calucateRatioBetweenMin:reduceThreshold Max:normalThreshold Now:dis_SmallToMain];
                ratio = 1 - ratio;
                CGFloat assisRadius_Main = [LineMath calucateValueBetweenMin:10 Max:30 Ratio:ratio];
                CGFloat assisRadius_Small = [LineMath calucateValueBetweenMin:10 Max:30 Ratio:ratio];
//                NSLog(@"ratio5555:%f", ratio);
                
                
                //  在小圆上的两个辅助点
                TwoPointStruct small_SideAssisPoint = [self calucateSideAssisBezierPointWithOriginPoint:dropView1.crossToCenterAssis_Point withDropView:dropView1 deltaDegree:[NSNumber numberWithFloat:assisRadius_Small]];
                dropView1.crossToLeftAssis_Point = small_SideAssisPoint.point1;
                dropView1.crossToRightAssis_Point = small_SideAssisPoint.point2;
                
                //  绘制辅助点，小圆上的
                PointMath *pointMath3= [[PointMath alloc] initWithPoint:dropView1.crossToLeftAssis_Point inView:self];
//                pointMath3.radius = [NSNumber numberWithFloat:3.0f];
                [_dropSuperView.assisArray addObject:pointMath3];

                PointMath *pointMath4 = [[PointMath alloc] initWithPoint:dropView1.crossToRightAssis_Point inView:self];
//                pointMath4.radius = [NSNumber numberWithFloat:3.0f];
                [_dropSuperView.assisArray addObject:pointMath4];
                
                
                
                //  在大圆上的两个辅助点
                TwoPointStruct main_SideAssisPoint = [self calucateSideAssisBezierPointWithOriginPoint:dropView1.crossToCenterAssis_PointMain withDropView:dropView2 deltaDegree:[NSNumber numberWithFloat:assisRadius_Main]];
                dropView1.crossToLeftAssis_PointMain = main_SideAssisPoint.point2;
                dropView1.crossToRightAssis_PointMain = main_SideAssisPoint.point1;
                
                //  绘制辅助点，大圆上的
                PointMath *pointMath5= [[PointMath alloc] initWithPoint:dropView1.crossToLeftAssis_PointMain inView:self];
//                pointMath5.radius = [NSNumber numberWithFloat:4.0f];
                [_dropSuperView.assisArray addObject:pointMath5];
    
                PointMath *pointMath6 = [[PointMath alloc] initWithPoint:dropView1.crossToRightAssis_PointMain inView:self];
//                pointMath6.radius = [NSNumber numberWithFloat:3.0f];
                [_dropSuperView.assisArray addObject:pointMath6];
            }
            //  粘滞状态
            else if (dis_SmallToMain < reduceThreshold){
//                NSLog(@"粘滞状态");
                
                CGFloat ratio = [LineMath calucateRatioBetweenMin:radius_SmallAddMain Max:reduceThreshold Now:dis_SmallToMain];
                ratio = 1 - ratio;
                CGFloat assisRadius_Main = [LineMath calucateValueBetweenMin:30 Max:44 Ratio:ratio];
                CGFloat assisRadius_Small = [LineMath calucateValueBetweenMin:30 Max:50 Ratio:ratio];
                //NSLog(@"ratio2222:%f", ratio);
                
                
                //  在小圆上的两个辅助点
                TwoPointStruct small_SideAssisPoint = [self calucateSideAssisBezierPointWithOriginPoint:dropView1.crossToCenterAssis_Point withDropView:dropView1 deltaDegree:[NSNumber numberWithFloat:assisRadius_Small]];
                dropView1.crossToLeftAssis_Point = small_SideAssisPoint.point1;
                dropView1.crossToRightAssis_Point = small_SideAssisPoint.point2;
                
                //            //  绘制辅助点，小圆上的
                //            PointMath *pointMath3= [[PointMath alloc] initWithPoint:dropView1.crossToLeftAssis_Point inView:self];
                //            pointMath3.radius = [NSNumber numberWithFloat:2.0f];
                //            [_dropSuperView.assisArray addObject:pointMath3];
                //
                //            PointMath *pointMath4 = [[PointMath alloc] initWithPoint:dropView1.crossToRightAssis_Point inView:self];
                //            pointMath4.radius = [NSNumber numberWithFloat:2.0f];
                //            [_dropSuperView.assisArray addObject:pointMath4];
                
                
                
                //  在大圆上的两个辅助点
                TwoPointStruct main_SideAssisPoint = [self calucateSideAssisBezierPointWithOriginPoint:dropView1.crossToCenterAssis_PointMain withDropView:dropView2 deltaDegree:[NSNumber numberWithFloat:assisRadius_Main]];
                dropView1.crossToLeftAssis_PointMain = main_SideAssisPoint.point2;
                dropView1.crossToRightAssis_PointMain = main_SideAssisPoint.point1;
                
                //            //  绘制辅助点，大圆上的
                //            PointMath *pointMath5= [[PointMath alloc] initWithPoint:dropView1.crossToLeftAssis_PointMain inView:self];
                //            pointMath5.radius = [NSNumber numberWithFloat:2.0f];
                //            [_dropSuperView.assisArray addObject:pointMath5];
                //
                //            PointMath *pointMath6 = [[PointMath alloc] initWithPoint:dropView1.crossToRightAssis_PointMain inView:self];
                //            pointMath6.radius = [NSNumber numberWithFloat:2.0f];
                //            [_dropSuperView.assisArray addObject:pointMath6];
            }
            
        }
            break;
            
        case kCross_SmallToMain:
        {
            CGFloat dis_SmallToMainThreshold = sqrt((dropView1.circleMath.radius - faultTolerantValue_SmallToSmall) * (dropView1.circleMath.radius - faultTolerantValue_SmallToSmall) * 2);
            
            //  动态计算辅助角度
            CGFloat ratio = [LineMath calucateRatioBetweenMin:dis_SmallToMainThreshold Max:radius_SmallAddMain Now:dis_SmallToMain];
            CGFloat assis_radius = [LineMath calucateValueBetweenMin:30 Max:50 Ratio:1 - ratio];
            
//            NSLog(@"ratio:%f", 1 - ratio);
//            NSLog(@"assis_radius:%f", assis_radius);
            
            NSNumber *assisRadius_Small = [NSNumber numberWithFloat:assis_radius];
//            NSNumber *assisRadius_Main = [NSNumber numberWithFloat:assis_radius];
            
//            LineMath *lineMath1 = [[LineMath alloc] initWithPoint1:dropView1.center point2:verLine.point1 inView:self];
//            [_dropSuperView.assisArray addObject:lineMath1];
            
//            PointMath *pointMath = [[PointMath alloc] initWithPoint:verLine.point1 inView:self];
//            [_dropSuperView.assisArray addObject:pointMath];
            
//            PointMath *pointMath = [[PointMath alloc] initWithPoint:verLine.point2 inView:self];
//            [_dropSuperView.assisArray addObject:pointMath];
            
            
            //  在小圆上的两个辅助点
            TwoPointStruct sideAssisPointRight = [self calucateSideAssisBezierPointWithOriginPoint:verLine.point1 withDropView:dropView1 deltaDegree:assisRadius_Small];
            dropView1.crossToRightAssis_Point = verLine.point1;
            dropView1.crossToRightAssis_PointS = sideAssisPointRight.point2;
            
            TwoPointStruct sideAssisPointLeft = [self calucateSideAssisBezierPointWithOriginPoint:verLine.point2 withDropView:dropView1 deltaDegree:assisRadius_Small];
            dropView1.crossToLeftAssis_Point = verLine.point2;
            dropView1.crossToLeftAssis_PointS = sideAssisPointLeft.point1;
            

            //  在大圆上的两个辅助点
//            TwoPointStruct mainSideAssisPointRight = [self calucateSideAssisBezierPointWithOriginPoint:verLine.point1 withDropView:dropView2 deltaDegree:assisRadius_Main];
//            
//            
//            TwoPointStruct mainSideAssisPointLeft = [self calucateSideAssisBezierPointWithOriginPoint:verLine.point2 withDropView:dropView2 deltaDegree:assisRadius_Main];
            
//            dropView1.crossToLeftAssis_PointMain = mainSideAssisPointLeft.point2;
//            dropView1.crossToRightAssis_PointMain = mainSideAssisPointRight.point1;
            
            dropView1.crossToLeftAssis_PointMain = verLine.point2;
            dropView1.crossToRightAssis_PointMain = verLine.point1;
            
            
            //  矫正
            [DropView eventInDiffQuadrantWithCenterPoint:_mainCenter
                                           withParaPoint:dropView1.center
                                           quadrantFirst:^{
                                               
                                           }
                                          quadrantSecond:^{
                                              
                                          }
                                           quadrantThird:^{
                                               dropView1.crossToRightAssis_Point = verLine.point2;
                                               dropView1.crossToLeftAssis_Point = verLine.point1;
                                               dropView1.crossToRightAssis_PointS = sideAssisPointLeft.point2;
                                               dropView1.crossToLeftAssis_PointS = sideAssisPointRight.point1;
//                                               dropView1.crossToRightAssis_PointMain = mainSideAssisPointLeft.point1;
//                                               dropView1.crossToLeftAssis_PointMain = mainSideAssisPointRight.point2;
                                               
                                               dropView1.crossToRightAssis_PointMain = verLine.point2;
                                               dropView1.crossToLeftAssis_PointMain = verLine.point1;
                                           }
                                          quadrantFourth:^{
                                              dropView1.crossToRightAssis_Point = verLine.point2;
                                              dropView1.crossToLeftAssis_Point = verLine.point1;
                                              dropView1.crossToRightAssis_PointS = sideAssisPointLeft.point2;
                                              dropView1.crossToLeftAssis_PointS = sideAssisPointRight.point1;
//                                              dropView1.crossToRightAssis_PointMain = mainSideAssisPointLeft.point1;
//                                              dropView1.crossToLeftAssis_PointMain = mainSideAssisPointRight.point2;
                                              
                                              dropView1.crossToRightAssis_PointMain = verLine.point2;
                                              dropView1.crossToLeftAssis_PointMain = verLine.point1;

                                          }];
            
            
            
//            //  绘制辅助点，小圆上的
//            PointMath *pointMath1 = [[PointMath alloc] initWithPoint:dropView1.crossToRightAssis_Point inView:self];
//            pointMath1.radius = [NSNumber numberWithFloat:2.0f];
//            [_dropSuperView.assisArray addObject:pointMath1];
//            
//            PointMath *pointMath2 = [[PointMath alloc] initWithPoint:dropView1.crossToRightAssis_PointS inView:self];
//            pointMath2.radius = [NSNumber numberWithFloat:2.0f];
//            [_dropSuperView.assisArray addObject:pointMath2];
//            
//            PointMath *pointMath3 = [[PointMath alloc] initWithPoint:dropView1.crossToLeftAssis_Point inView:self];
//            pointMath3.radius = [NSNumber numberWithFloat:2.0f];
//            [_dropSuperView.assisArray addObject:pointMath3];
//            
//            PointMath *pointMath4 = [[PointMath alloc] initWithPoint:dropView1.crossToLeftAssis_PointS inView:self];
//            pointMath4.radius = [NSNumber numberWithFloat:2.0f];
//            [_dropSuperView.assisArray addObject:pointMath4];
//            
//            
            //  绘制辅助点，大圆上的
            PointMath *pointMath6 = [[PointMath alloc] initWithPoint:dropView1.crossToRightAssis_PointMain inView:self];
            pointMath6.radius = [NSNumber numberWithFloat:3.0f];
            [_dropSuperView.assisArray addObject:pointMath6];
            
            PointMath *pointMath8 = [[PointMath alloc] initWithPoint:dropView1.crossToLeftAssis_PointMain inView:self];
            pointMath8.radius = [NSNumber numberWithFloat:3.0f];
            [_dropSuperView.assisArray addObject:pointMath8];
        }
            break;
            
        case kCross_SmallToSmall:
        {
            //  动态计算辅助角度
            CGFloat ratio = [LineMath calucateRatioBetweenMin:0 Max:radius_SmallAddSmall Now:dis_SmallToSmall];
            CGFloat assis_radius = [LineMath calucateValueBetweenMin:0 Max:35 Ratio:ratio];
            
            //  外侧的点
            CGPoint outerPoint = [LineMath calucatePointWithOriginPoint:_mainCenter point1:verLine.point1 point2:verLine.point2 condition:kFar];
            
            PointMath *pointMath1 = [[PointMath alloc] initWithPoint:outerPoint inView:self];
            [_dropSuperView.assisArray addObject:pointMath1];
            
            //  圆与圆交点两侧的辅助点
            TwoPointStruct sideAssisPoint = [self calucateSideAssisBezierPointWithOriginPoint:outerPoint withDropView:dropView1 deltaDegree:[NSNumber numberWithFloat:assis_radius]];
            
            if (setCondition == kSetRightPoint) {
                dropView1.crossToRightAssis_Point = outerPoint;
                dropView1.crossToRightAssis_PointS = sideAssisPoint.point1;
            }else if (setCondition == kSetLeftPoint){
                dropView1.crossToLeftAssis_Point = outerPoint;
                dropView1.crossToLeftAssis_PointS = sideAssisPoint.point1;
            }
            
            
            PointMath *pointMath2 = [[PointMath alloc] initWithPoint:dropView1.crossToRightAssis_Point inView:self];
            pointMath2.radius = [NSNumber numberWithFloat:2.0f];
            [_dropSuperView.assisArray addObject:pointMath2];
            
            PointMath *pointMath3 = [[PointMath alloc] initWithPoint:dropView1.crossToLeftAssis_PointS inView:self];
            pointMath3.radius = [NSNumber numberWithFloat:2.0f];
            [_dropSuperView.assisArray addObject:pointMath3];
        }
            break;
            
        default:
            break;
    }
    
    return acrossPointStruct;
}

//  计算DropView上某点附近的点，用于平滑贝塞尔曲线
- (TwoPointStruct)calucateSideAssisBezierPointWithOriginPoint:(CGPoint)originPoint withDropView:(DropView *)dropView deltaDegree:(NSNumber *)deltaDegree
{
    CGFloat deltaDegrees = 60;
    if (deltaDegree) {
        deltaDegrees = [deltaDegree floatValue];
    }
    
    TwoPointStruct twoPointStruct;
    
    //  点和圆心的连线
    CGPoint dropViewCenter = dropView.center;
    if ([dropView isEqual:self]) {
        dropViewCenter = _mainCenter;
    }
    
    LineMath *lineMathOrigin = [[LineMath alloc] initWithPoint1:dropViewCenter point2:originPoint inView:self];
//    [_dropSuperView.assisArray addObject:lineMathOrigin];
    
    CGFloat angleOrigin;
    
    switch (lineMathOrigin.lineStatus) {
        case kLineNormal:
        {
            angleOrigin = atan(lineMathOrigin.k);
        }
            break;
            
        case kLineHorizontal:
        {
            angleOrigin = 0;
        }
            break;
            
        case kLineVertical:
        {
            angleOrigin = M_PI / 2.0f;
        }
            break;
            
        default:
            break;
    }
    
    CGFloat deltaAngle = degreesToRadian(deltaDegrees);
    
    LineMath *line1 = [[LineMath alloc] init];
    line1.k = tan(angleOrigin + deltaAngle);
    line1.b = dropViewCenter.y - line1.k * dropViewCenter.x;
    AcrossPointStruct acrossPointStruct1 = [self calucateCircleAndLineAcrossPoint_withCircle:dropView.circleMath withLine:line1];
    
    LineMath *line2 = [[LineMath alloc] init];
    line2.k = tan(angleOrigin - deltaAngle);
    line2.b = dropViewCenter.y - line2.k * dropViewCenter.x;
    AcrossPointStruct acrossPointStruct2 = [self calucateCircleAndLineAcrossPoint_withCircle:dropView.circleMath withLine:line2];
    
    twoPointStruct.point1 = [LineMath calucatePointWithOriginPoint:originPoint point1:acrossPointStruct1.point1 point2:acrossPointStruct1.point2 condition:kNear];
    twoPointStruct.point2 = [LineMath calucatePointWithOriginPoint:originPoint point1:acrossPointStruct2.point1 point2:acrossPointStruct2.point2 condition:kNear];
    
    //  小圆相交时，只获取外侧的点
    if (_relation == kCross_SmallToSmall) {
        twoPointStruct.point1 = [LineMath calucatePointWithOriginPoint:_mainCenter point1:twoPointStruct.point1 point2:twoPointStruct.point2 condition:kFar];
        twoPointStruct.point2 = twoPointStruct.point1;
    }
    
    return twoPointStruct;
}


#pragma mark - 已知过圆的直线方程，求圆与直线的两个交点
/** 已知过圆的直线方程，求圆与直线的两个交点
 *
 *  1，圆的方程
 *  dx方 = (x2 - x1)方 + (y2 - y1)方
 *  2，直线方程
 *  y = kx + b
 *
 *  联立1，2方程式，得出二次函数
 *  ax方 + bx + c = 0
 *  其中：
 *  a = ((kLine * kLine) + 1)
 *  b = - ((2 * x0) - (2 * kLine * bLine) + (2 * kLine * y0))
 *  c = (x0 * x0) + (bLine * bLine) - (2 * bLine * y0) + (y0 * y0) - (dx * dx)
 *  delta = b方 - 4ac
 *  解出该二次函数的两个根，就能得出圆与直线的两个交点的x值，从而得出圆与直线的两个交点的坐标
 *
 *  参数说明
 *  (x0, y0)    圆心坐标
 *  kLine       直线的斜率
 *  bLine       直线的b参数
 *  dx          圆的半径
 *  a,b,c,delta 上面都已说明，不再解释
 */
- (AcrossPointStruct)calucateCircleAndLineAcrossPoint_withCircle:(CircleMath *)circle withLine:(LineMath *)line
{
    CGPoint tempCenter = [self convertPoint:circle.centerPoint fromView:circle.InView];
    CGFloat x0 = tempCenter.x;
    CGFloat y0 = tempCenter.y;
    
    CGFloat kLine = line.k;
    CGFloat bLine = line.b;
    
    CGFloat r = circle.radius;
    CGFloat a = ((kLine * kLine) + 1);
    CGFloat b = - ((2 * x0) - (2 * kLine * bLine) + (2 * kLine * y0));
    CGFloat c = (x0 * x0) + (bLine * bLine) - (2 * bLine * y0) + (y0 * y0) - (r * r);
    AcrossPointStruct acrossPointStruct;
    
    switch (line.lineStatus) {
        case kLineNormal:
        {
            float delta = (b * b) - (4 * a * c);
            if (delta > 0) {
                //        NSLog(@"两个根");
                
                CGFloat x1_result = ((-b) - sqrt(delta)) / (2 * a);
                CGFloat y1_result = (kLine * x1_result) + bLine;
                
                CGFloat x2_result = ((-b) + sqrt(delta)) / (2 * a);
                CGFloat y2_result = (kLine * x2_result) + bLine;
                
                acrossPointStruct.point1 = CGPointMake(x1_result, y1_result);
                acrossPointStruct.point2 = CGPointMake(x2_result, y2_result);
                
                //  edgePoint矫正
                switch (_smallDropQuadrant) {
                        //  第一象限
                    case kQuadrant_First:
                        acrossPointStruct.point1 = CGPointMake(x2_result, y2_result);
                        acrossPointStruct.point2 = CGPointMake(x1_result, y1_result);
                        break;
                        
                        //  第二象限
                    case kQuadrant_Second:
                        acrossPointStruct.point1 = CGPointMake(x2_result, y2_result);
                        acrossPointStruct.point2 = CGPointMake(x1_result, y1_result);
                        break;
                        
                        //  第三象限
                    case kQuadrant_Third:
                        
                        break;
                        
                        //  第四象限
                    case kQuadrant_Fourth:
                        
                        break;
                        
                    default:
                        break;
                }
                
            }else if (delta == 0){
                //        NSLog(@"圆与直线 一个交点");
            }else{
                //        NSLog(@"圆与直线 无交点");
            }
        }
            break;
            
        case kLineHorizontal:
        {
            CGFloat y_dis = [LineMath calucateDistanceBetweenPoint1:tempCenter withPoint2:line.tempCenter];
            CGFloat x_dis = sqrt(r * r - y_dis * y_dis);
            acrossPointStruct.point1 = CGPointMake(line.tempCenter.x - x_dis, line.tempCenter.y);
            acrossPointStruct.point2 = CGPointMake(line.tempCenter.x + x_dis, line.tempCenter.y);
        }
            break;
            
        case kLineVertical:
        {
            CGFloat x_dis = [LineMath calucateDistanceBetweenPoint1:tempCenter withPoint2:line.tempCenter];
            CGFloat y_dis = sqrt(r * r - x_dis * x_dis);
            acrossPointStruct.point1 = CGPointMake(line.tempCenter.x, line.tempCenter.y - y_dis);
            acrossPointStruct.point2 = CGPointMake(line.tempCenter.x, line.tempCenter.y + y_dis);
        }
            break;
            
        default:
            break;
    }
    
    return acrossPointStruct;
}

//  计算两点连线的垂直平分线
- (LineMath *)PerBaseLine_Point1:(CGPoint)point1 Point2:(CGPoint)point2
{
    LineMath *originMathLine = [[LineMath alloc] initWithPoint1:point1 point2:point2 inView:self];
    CGPoint centerPoint = [LineMath calucateCenterPointBetweenPoint1:point1 withPoint2:point2];
    
    LineMath *perBiseLine = [[LineMath alloc] init];
    CGFloat angle = atan(originMathLine.k);
    angle += M_PI/2;
    if (angle > M_PI/2) {
        angle -= M_PI;
    }else if (angle < - M_PI/2){
        angle += M_PI;
    }
    perBiseLine.k = tan(angle);
    perBiseLine.b = centerPoint.y - perBiseLine.k * centerPoint.x;
    
    return perBiseLine;
}

/** 判断点所处象限
 *
 *  centerPoint 作为圆心的点
 *  paraPoint   以centerPoint为坐标原点，判断paraPoint所在的象限
 *
 *  quadrantFirst   第一象限
 *  quadrantSecond  第二象限
 *  quadrantThird   第三象限
 *  quadrantFourth  第四象限
 */
+ (void)eventInDiffQuadrantWithCenterPoint:(CGPoint)centerPoint
                             withParaPoint:(CGPoint)paraPoint
                             quadrantFirst:(void (^)())quadrantFirst
                            quadrantSecond:(void (^)())quadrantSecond
                             quadrantThird:(void (^)())quadrantThird
                            quadrantFourth:(void (^)())quadrantFourth
{
    //  第一象限
    if (centerPoint.x <= paraPoint.x && centerPoint.y >= paraPoint.y) {
        if (quadrantFirst) {
            quadrantFirst();
        }
    }
    //  第二象限
    else if (centerPoint.x > paraPoint.x && centerPoint.y >= paraPoint.y){
        if (quadrantSecond) {
            quadrantSecond();
        }
    }
    //  第三象限
    else if (centerPoint.x > paraPoint.x && centerPoint.y < paraPoint.y){
        if (quadrantThird) {
            quadrantThird();
        }
    }
    //  第四象限
    else if (centerPoint.x <= paraPoint.x && centerPoint.y < paraPoint.y){
        if (quadrantFourth) {
            quadrantFourth();
        }
    }
}

+ (BOOL)JudgeEqualWithPoint1:(CGPoint)point1 point2:(CGPoint)point2
{
    BOOL res1 = ((int)point1.x == (int)point2.x);
    BOOL res2 = ((int)point1.y == (int)point2.y);
    
    if (res1 && res2) {
        return YES;
    }
    
    return NO;
}

/** 根据两点和比例计算其他点
 *
 *  point1,point2   两源点
 *  ratio           距两个端点距离占线段总长度的比例
 *  twoPointStruct  最终返回的两点的结构体
 *  注：
 *      ratio小于0的情况下，twoPointStruct.point1在中点和point2之间
 *      ratio等于0的情况下，twoPointStruct.point1为中点
 *      ratio等于1的情况下，twoPointStruct.point1为point1
 *      ratio大于1的情况下，twoPointStruct.point1为超过point1的点
 *      反之亦然
 */
+ (TwoPointStruct)PointBetweenPoint1:(CGPoint)point1 point2:(CGPoint)point2 ToPointRatio:(CGFloat)ratio
{
    TwoPointStruct twoPointStruct;
    
    CGFloat xAll = point1.x + point2.x;
    CGFloat yAll = point1.y + point2.y;
    
    CGFloat xDis = point2.x - point1.x;
    CGFloat yDis = point2.y - point1.y;
    
    CGFloat xRes1 = (xAll - xDis * ratio)/2.0f;
    CGFloat yRes1 = (yAll - yDis * ratio)/2.0f;
    
    CGFloat xRes2 = (xAll + xDis * ratio)/2.0f;
    CGFloat yRes2 = (yAll + yDis * ratio)/2.0f;
    
    twoPointStruct.point1 = CGPointMake(xRes1, yRes1);
    twoPointStruct.point2 = CGPointMake(xRes2, yRes2);
    
    return twoPointStruct;
}

//  把某点转化成圆上对应的角度
+ (CGFloat)ConvertPointToRadiusInDropView:(DropView *)dropView point:(CGPoint)point canvansView:(UIView *)canvansView
{
    CALayer *dropView_PreLayer = dropView.layer.presentationLayer;
    CGPoint dropView_center = [dropView convertPoint:dropView_PreLayer.position toView:canvansView];
    CGPoint point1 = [dropView convertPoint:point toView:canvansView];
    
    //  MainDrop半圆
    LineMath *line = [[LineMath alloc] initWithPoint1:point1 point2:dropView_center inView:canvansView];
    
    __block CGFloat radius = atan(line.k);
    
    //  两圆焦点和圆心连线的line的 斜率矫正
    [DropView eventInDiffQuadrantWithCenterPoint:dropView_center withParaPoint:point1 quadrantFirst:^{
        nil;
    } quadrantSecond:^{
        radius -= M_PI;
    } quadrantThird:^{
        radius -= M_PI;
    } quadrantFourth:^{
        nil;
    }];
    
    return radius;
}

@synthesize fillColor = _fillColor;
- (void)setFillColor:(UIColor *)fillColor
{
    _fillColor = fillColor;
    _dropShapLayer.fillColor = _fillColor.CGColor;
}

@end





