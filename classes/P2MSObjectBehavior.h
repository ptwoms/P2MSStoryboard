//
//  P2MSObjectBehavior.h
//  P2MSStoryboard
//
//  Created by PYAE PHYO MYINT SOE on 16/1/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "P2MSAbstractObject.h"

@class P2MSObjectBehavior;
@class P2MSAnimationObject;

@protocol P2MSObjectBehaviorDelegate <NSObject>

- (void)behaviorDone:(P2MSObjectBehavior *)behavior;

@end

@protocol P2MSObjectBehavior <NSObject>

@property (nonatomic, unsafe_unretained) id<P2MSObjectBehaviorDelegate> delegate;//or assign
@property (nonatomic, retain) NSArray *parameters;
@property (nonatomic) CGFloat animPeriod;

- (id) initWithParameters:(NSString *)params andAnimPeriod:(CGFloat)animationPeriod;
- (id)initWithParameterArray:(NSArray *)params andAnimPeriod:(CGFloat)animationPeriod;
- (void)performBehaviorOnObject:(id<P2MSAbstractObject>)animObject;

@end
