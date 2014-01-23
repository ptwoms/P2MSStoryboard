//
//  P2MSObjectAnimationFactory.m
//  P2MSStoryboard
//
//  Created by PYAE PHYO MYINT SOE on 16/1/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "P2MSObjectAnimationFactory.h"
#import "P2MSStandarBehaviors.h"


@implementation P2MSObjectAnimationFactory

+ (id<P2MSObjectBehavior>)getBehaviorFromVerb:(NSString *)animVerb andParams:(NSArray *)params{
    id<P2MSObjectBehavior> behavior = nil;
    NSArray *animParams = nil;
    if (params.count > 2) {
        animParams = [params subarrayWithRange:NSMakeRange(2, params.count-2)];
    }
    if ([animVerb isEqualToString:@"move"]) {
        behavior = [[P2MSMoveBehavior alloc]initWithParameterArray:animParams andAnimPeriod:[[params objectAtIndex:1]floatValue]];
    }
    return behavior;
}

@end
