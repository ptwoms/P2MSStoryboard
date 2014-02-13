//
//  P2MSStandarBehavior.m
//  P2MSStoryboard
//
//  Created by PYAE PHYO MYINT SOE on 16/1/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "P2MSStandarBehaviors.h"
#import "P2MSAnimationObject.h"
#import "P2MSObjectWrapper.h"

@interface P2MSStandardBehavior()

@property (nonatomic, readonly) BOOL hasDelegate;
@end

@implementation P2MSStandardBehavior
@synthesize delegate = _delegate;
@synthesize parameters;
@synthesize animPeriod;

- (id)initWithParameters:(NSString *)params andAnimPeriod:(CGFloat)animationPeriod{
    NSArray *arr = [params componentsSeparatedByString:@","];
    self = [self initWithParameterArray:arr andAnimPeriod:animationPeriod];
    return self;
}

- (id)initWithParameterArray:(NSArray *)params andAnimPeriod:(CGFloat)animationPeriod{
    if (self = [super init]) {
        self.parameters = params;
        self.animPeriod = animationPeriod;
        _hasDelegate = NO;
    }
    return self;
}

- (void)setDelegate:(id<P2MSObjectBehaviorDelegate>)delegate{
    _delegate = delegate;
    _hasDelegate = [_delegate respondsToSelector:@selector(behaviorDone:)];
}

- (void)performBehaviorOnObject:(P2MSAnimationObject *)animObject{
    //required to override by the subclass
}

@end

/////////////////////////////////////////////////
// Move Behavior
/////////////////////////////////////////////////
//@interface P2MSMoveBehavior(){
//    UIView *object;
//}
//@end

@implementation P2MSMoveBehavior

- (void)performBehaviorOnObject:(P2MSAnimationObject *)animObject{
    UIView *_animateView = animObject.view;
//    object = _animateObject;
//    CGRect finalRect = [_animateObject frame];
//    CGPoint newPoint;
//    newPoint.x = [P2MSObjectWrapper getPosFromString:[self.parameters objectAtIndex:0] withParentView:_animateObject.superview];
//    newPoint.y = [P2MSObjectWrapper getPosFromString:[self.parameters objectAtIndex:1] withParentView:_animateObject.superview];
//    CGPoint curPos = _animateObject.layer.position;
//    CGPoint posDiff = CGPointMake(finalRect.origin.x-newPoint.x, finalRect.origin.y-newPoint.y);
//    CGPoint newPos = CGPointMake(curPos.x-posDiff.x, curPos.y-posDiff.y);
//    CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
//    theAnimation.delegate = self;
//    theAnimation.duration = self.animPeriod;
//    theAnimation.removedOnCompletion = NO;
//    theAnimation.fillMode = kCAFillModeForwards;
//    theAnimation.fromValue = [NSValue valueWithCGPoint:curPos];
//    theAnimation.toValue = [NSValue valueWithCGPoint:newPos];
//    [_animateObject.layer addAnimation:theAnimation forKey:@"position"];

    if ([_animateView isKindOfClass:[UIImageView class]]) {
        [(UIImageView *)_animateView startAnimating];
    }
    CGRect finalRect = [_animateView bounds];
    finalRect.origin.x = [P2MSObjectWrapper getPosFromString:[self.parameters objectAtIndex:0] withParentView:_animateView.superview];
    finalRect.origin.y = [P2MSObjectWrapper getPosFromString:[self.parameters objectAtIndex:1] withParentView:_animateView.superview];
    CGPoint newCenter = CGPointMake(finalRect.origin.x + (finalRect.size.width/2), finalRect.origin.y + (finalRect.size.height/2));
    [UIView animateWithDuration:self.animPeriod animations:^{
        _animateView.center =  newCenter;
    }completion:^(BOOL finished) {
        if ([_animateView isKindOfClass:[UIImageView class]]) {
            [(UIImageView *)_animateView stopAnimating];
        }
        if (finished && self.hasDelegate) {
            [self.delegate behaviorDone:(P2MSObjectBehavior *)self];
        }
    }];
}

//- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
//    object.layer.position = ((CALayer *)((UIView *)object).layer.presentationLayer).position;
//    if (flag && self.hasDelegate) {
//        [self.delegate behaviorDone:(P2MSObjectBehavior *)self];
//    }
//}

@end

/////////////////////////////////////////////////
// Move Scale Behavior
/////////////////////////////////////////////////
@implementation P2MSMoveScaleBehavior
@synthesize parameters = _parameters;

- (void)performBehaviorOnObject:(P2MSAnimationObject *)animObject{
    UIView *_animateView = animObject.view;
    if ([_animateView isKindOfClass:[UIImageView class]]) {
        [(UIImageView *)_animateView startAnimating];
    }
    [UIView animateWithDuration:self.animPeriod animations:^{
        CGRect finalRect = [_animateView bounds];
        finalRect.origin.x = [P2MSObjectWrapper getPosFromString:[_parameters objectAtIndex:0] withParentView:_animateView.superview];
        finalRect.origin.y = [P2MSObjectWrapper getPosFromString:[_parameters objectAtIndex:1] withParentView:_animateView.superview];
        finalRect.size.width = [P2MSObjectWrapper getScaleValueFromString:[_parameters objectAtIndex:2] withOriginalWidth:_animateView.bounds.size.width];
        finalRect.size.height = [P2MSObjectWrapper getScaleValueFromString:[_parameters objectAtIndex:3] withOriginalWidth:_animateView.bounds.size.height];
        _animateView.frame =  finalRect;
    }completion:^(BOOL finished) {
        if ([_animateView isKindOfClass:[UIImageView class]]) {
            [(UIImageView *)_animateView stopAnimating];
        }
        if (finished && self.hasDelegate) {
            [self.delegate behaviorDone:(P2MSObjectBehavior *)self];
        }
    }];
}
@end

/////////////////////////////////////////////////
// ImageAnimation Behavior
/////////////////////////////////////////////////
@implementation P2MSImageAnimationBehavior

- (void)performBehaviorOnObject:(id<P2MSAbstractObject>)animObject{
    UIView *_animateView = animObject.view;
    if ([_animateView isKindOfClass:[UIImageView class]]) {
        NSArray *imageNames = [[self.parameters objectAtIndex:2]componentsSeparatedByString:@"#"];
        if (imageNames.count) {
            NSMutableArray *images = [NSMutableArray array];
            for (NSString *imageName in imageNames) {
                [images addObject:[UIImage imageNamed:imageName]];
            }
            ((UIImageView *)_animateView).image = [images lastObject];
            [((UIImageView *)_animateView) setAnimationImages:images];
        }
        NSString *period = [self.parameters objectAtIndex:0];
        if (period.length) {
            CGFloat animPeriod = [period floatValue];
            ((UIImageView *)_animateView).animationDuration = animPeriod;
        }
        NSString *count = [self.parameters objectAtIndex:1];
        if (count.length) {
            CGFloat animCount = [count floatValue];
            ((UIImageView *)_animateView).animationRepeatCount = (animCount == 0)?CGFLOAT_MAX:animCount;
        }
        [((UIImageView *)_animateView) startAnimating];
    }
    if (self.hasDelegate) {
        [self.delegate behaviorDone:(P2MSObjectBehavior *)self];
    }
}

@end


/////////////////////////////////////////////////
// Rotate Behavior
/////////////////////////////////////////////////
@implementation P2MSRotateBehavior

- (void)performBehaviorOnObject:(P2MSAnimationObject *)animObject{
    UIView *_animateView = animObject.view;
    CGFloat degree = [[self.parameters objectAtIndex:0]floatValue];
//    if (self.animPeriod > 0) {
        [UIView animateWithDuration:self.animPeriod animations:^{
            _animateView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(degree));
        }completion:^(BOOL finished) {
            if ([_animateView isKindOfClass:[UIImageView class]]) {
                [(UIImageView *)_animateView stopAnimating];
            }
            if (finished && self.hasDelegate) {
                [self.delegate behaviorDone:(P2MSObjectBehavior *)self];
            }
        }];
//    }else{
//        _animateView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(degree));
//        if (self.hasDelegate) {
//            [self.delegate behaviorDone:(P2MSObjectBehavior *)self];
//        }
//    }
}
@end


/////////////////////////////////////////////////
// Rotate Behavior
/////////////////////////////////////////////////
@implementation P2MSClockRotateBehavior

- (void)performBehaviorOnObject:(P2MSAnimationObject *)animObject{
    UIView *_animateView = animObject.view;
    CGFloat repeatCount = [[self.parameters objectAtIndex:0]floatValue];
    CALayer *layer = _animateView.layer;
    CAKeyframeAnimation *animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.duration = self.animPeriod;
    animation.cumulative = YES;
    animation.additive = YES;
    animation.calculationMode = kCAAnimationDiscrete;
    animation.repeatCount = (repeatCount>0)?repeatCount:CGFLOAT_MAX;
    NSMutableArray *animationValues = [NSMutableArray array];
    NSMutableArray *animationTimes = [NSMutableArray array];
    CGFloat prevValue = 0, intervalVal = 0.104719755;//6.28318531
    CGFloat prevTimeValue = 0, intervalTimeVal = 0.01666666666;
    for (int i = 0; i < 60; i++) {
        [animationValues addObject:[NSNumber numberWithFloat:prevValue]];
        [animationTimes addObject:[NSNumber numberWithFloat:prevTimeValue]];
        prevValue += intervalVal;
        prevTimeValue += intervalTimeVal;
    }
    animation.delegate = self;
    animation.values = animationValues;
    animation.keyTimes = animationTimes;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [layer addAnimation:animation forKey:nil];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (flag && self.hasDelegate) {
        [self.delegate behaviorDone:(P2MSObjectBehavior *)self];
    }
}

@end

/////////////////////////////////////////////////
// Flip-Rotate Behavior
/////////////////////////////////////////////////
@implementation P2MSFlipRotateBehavior

- (void)performBehaviorOnObject:(P2MSAnimationObject *)animObject{
    UIView *_animateView = animObject.view;
    CGFloat horX = [[self.parameters objectAtIndex:0]floatValue];
    CGFloat verY = [[self.parameters objectAtIndex:1]floatValue];
    CGFloat degree = [[self.parameters objectAtIndex:2]floatValue];
    CGAffineTransform trans = CGAffineTransformMakeScale(horX, verY);
    trans = CGAffineTransformRotate(trans, DEGREES_TO_RADIANS(degree));
    [UIView animateWithDuration:self.animPeriod animations:^{
        _animateView.transform = trans;
    }completion:^(BOOL finished) {
        if ([_animateView isKindOfClass:[UIImageView class]]) {
            [(UIImageView *)_animateView stopAnimating];
        }
        if (finished && self.hasDelegate) {
            [self.delegate behaviorDone:(P2MSObjectBehavior *)self];
        }
    }];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (flag && self.hasDelegate) {
        [self.delegate behaviorDone:(P2MSObjectBehavior *)self];
    }
}

@end

/////////////////////////////////////////////////
// Fade Behavior
/////////////////////////////////////////////////
@implementation P2MSAlphaBehavior

- (void)performBehaviorOnObject:(P2MSAnimationObject *)animObject{
    UIView *_animateView = animObject.view;
    CGFloat alpha = [[self.parameters objectAtIndex:0]floatValue];
    [UIView animateWithDuration:self.animPeriod animations:^{
        _animateView.alpha = alpha;
    }completion:^(BOOL finished) {
        if (finished && self.hasDelegate) {
            [self.delegate behaviorDone:(P2MSObjectBehavior *)self];
        }
    }];
}

@end

/////////////////////////////////////////////////
// Replace Image
/////////////////////////////////////////////////
@implementation ReplaceImage

- (void)performBehaviorOnObject:(P2MSAnimationObject *)animObject{
    if (![animObject.view isKindOfClass:[UIImageView class]]) {
        return;
    }
    UIImageView *_animateView = (UIImageView *)animObject.view;
    [_animateView stopAnimating];
    NSString *imageName = [self.parameters objectAtIndex:0];
    UIImage *imageToReplace = [UIImage imageNamed:imageName];
    [_animateView setImage:imageToReplace];
    CGRect curRect = _animateView.frame;
    NSUInteger animCount = self.parameters.count;
    if (animCount > 2) {
        NSString *newXPos = [self.parameters objectAtIndex:1];
        if (newXPos.length) {
            curRect.origin.x = [P2MSObjectWrapper getPosFromString:newXPos withParentView:_animateView.superview];
        }
        if (animCount > 3) {
            NSString *newYPos = [self.parameters objectAtIndex:2];
            if (newYPos.length) {
                curRect.origin.y = [P2MSObjectWrapper getPosFromString:newYPos withParentView:_animateView.superview];
            }
            if (animCount > 4) {
                NSString *newWidth = [self.parameters objectAtIndex:3];
                if (newWidth.length) {
                    curRect.size.width = [newWidth floatValue];
                }else
                    curRect.size.width = imageToReplace.size.width;
                if (animCount > 5) {
                    NSString *newHeight = [self.parameters objectAtIndex:4];
                    if (newHeight.length) {
                        curRect.size.height = [newHeight floatValue];
                    }else
                        curRect.size.height = imageToReplace.size.height;
                }
            }
        }
    }
    _animateView.frame = curRect;
    if (self.hasDelegate) {
        [self.delegate behaviorDone:(P2MSObjectBehavior *)self];
    }
}
@end


/////////////////////////////////////////////////
// Reset Transform
/////////////////////////////////////////////////
@implementation ResetTransform

- (void)performBehaviorOnObject:(P2MSAnimationObject *)animObject{
    UIView *_animateView = animObject.view;
    _animateView.transform = CGAffineTransformIdentity;
    if (self.hasDelegate) {
        [self.delegate behaviorDone:(P2MSObjectBehavior *)self];
    }
}
@end

/////////////////////////////////////////////////
// Dependency to other object
/////////////////////////////////////////////////
@interface AnimationObjectDependency(){
    NSInteger serialIndex, subIndex, repeatCount, object_tag;
}

@end

@implementation AnimationObjectDependency

- (void)performBehaviorOnObject:(P2MSAnimationObject *)animObject{
    object_tag = [[self.parameters objectAtIndex:0]integerValue];
    serialIndex = [[self.parameters objectAtIndex:1]integerValue];
    subIndex = [[self.parameters objectAtIndex:2]integerValue];
    if (self.parameters.count > 3) {
        repeatCount = [[self.parameters objectAtIndex:3]integerValue];
    }else
        repeatCount = 1;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(behaviorDone:) name:OBJECT_ANIMATION_DONE_NOTIFICATION object:nil];
}

- (void)behaviorDone:(NSNotification *)notif{
    NSDictionary *dict = [notif userInfo];
    NSInteger animSerialIndex = [[dict objectForKey:@"animationSerialIndex"]integerValue];
    NSInteger animSubIndex = [[dict objectForKey:@"animationIndex"]integerValue];
    NSInteger tag = [[dict objectForKey:@"object_tag"]integerValue];
    if (object_tag == tag &&  animSerialIndex == serialIndex && subIndex == animSubIndex && self.hasDelegate) {
        repeatCount--;
        if (repeatCount == 0) {
            [[NSNotificationCenter defaultCenter]removeObserver:self name:OBJECT_ANIMATION_DONE_NOTIFICATION object:nil];
            [self.delegate behaviorDone:(P2MSObjectBehavior *)self];
        }
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:OBJECT_ANIMATION_DONE_NOTIFICATION object:nil];
}


@end


