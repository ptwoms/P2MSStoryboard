//
//  P2MSObjectBehavior.h
//  P2MSStoryboard
//
//  Created by PYAE PHYO MYINT SOE on 16/1/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import <Foundation/Foundation.h>

@class P2MSObjectBehavior;
@class P2MSAnimationObject;

@protocol P2MSObjectBehaviorDelegate <NSObject>

- (void)behaviorDone:(P2MSObjectBehavior *)behavior;

@end

@protocol P2MSObjectBehavior <NSObject>

@property (nonatomic, weak) id<P2MSObjectBehaviorDelegate> delegate;//or assign
@property (nonatomic, retain) NSArray *parameters;
@property (nonatomic) CGFloat animPeriod;

- (id) initWithParameters:(NSString *)params andAnimPeriod:(CGFloat)animationPeriod;
- (id)initWithParameterArray:(NSArray *)params andAnimPeriod:(CGFloat)animationPeriod;
- (void)performBehaviorOnObject:(P2MSAnimationObject *)animObject;

@end
