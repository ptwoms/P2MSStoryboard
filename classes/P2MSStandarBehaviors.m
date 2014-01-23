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

@interface P2MSMoveBehavior(){
    BOOL hasDelegate;
}

@end

@implementation P2MSMoveBehavior
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
        hasDelegate = NO;
    }
    return self;
}

- (void)setDelegate:(id<P2MSObjectBehaviorDelegate>)delegate{
    _delegate = delegate;
    hasDelegate = [_delegate respondsToSelector:@selector(behaviorDone:)];
}

- (void)performBehaviorOnObject:(P2MSAnimationObject *)animObject{
    UIImageView *_animateObject = animObject.imageObject;
    [UIView animateWithDuration:animPeriod animations:^{
        CGRect finalRect = [_animateObject bounds];
        finalRect.origin.x = [P2MSObjectWrapper getPosFromString:[parameters objectAtIndex:0] withParentView:_animateObject.superview];
        finalRect.origin.y = [P2MSObjectWrapper getPosFromString:[parameters objectAtIndex:1] withParentView:_animateObject.superview];
        CGPoint newCenter = CGPointMake(finalRect.origin.x + (finalRect.size.width/2), finalRect.origin.y + (finalRect.size.height/2));
        _animateObject.center =  newCenter;
        [_animateObject startAnimating];
    }completion:^(BOOL finished) {
        [_animateObject stopAnimating];
        if (finished && hasDelegate) {
            [self.delegate behaviorDone:(P2MSObjectBehavior *)self];
        }
    }];
}

@end
