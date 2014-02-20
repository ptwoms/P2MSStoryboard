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

+ (id<P2MSObjectBehavior>)getBehaviorFromVerb:(NSString *)animVerb andParams:(NSArray *)params forObjectType:(OBJECT_TYPE)objectType{
    id<P2MSObjectBehavior> behavior = nil;
    if ([animVerb hasPrefix:@"s_"]) {
        NSArray *animParams = nil;
        if (params.count > 2) {
            animParams = [params subarrayWithRange:NSMakeRange(2, params.count-2)];
        }
        if ([animVerb hasPrefix:@"s_move"]) {
            if ([animVerb hasSuffix:@"scale"]) {
                behavior = [[P2MSMoveScaleBehavior alloc]initWithParameterArray:animParams andAnimPeriod:[[params objectAtIndex:1]floatValue]];
            }else{
                behavior = [[P2MSMoveBehavior alloc]initWithParameterArray:animParams andAnimPeriod:[[params objectAtIndex:1]floatValue]];
            }
        }else if ([animVerb rangeOfString:@"rotate"].length > 0){
            if ([animVerb hasPrefix:@"s_clock"]) {
                behavior = [[P2MSClockRotateBehavior alloc]initWithParameterArray:animParams andAnimPeriod:[[params objectAtIndex:1]floatValue]];
            }else if([animVerb hasPrefix:@"s_flip"]){
                behavior = [[P2MSFlipRotateBehavior alloc]initWithParameterArray:animParams andAnimPeriod:[[params objectAtIndex:1]floatValue]];
            }else{
                behavior = [[P2MSRotateBehavior alloc]initWithParameterArray:animParams andAnimPeriod:[[params objectAtIndex:1]floatValue]];
            }
        }else if ([animVerb isEqualToString:@"s_alpha"]){
            behavior = [[P2MSAlphaBehavior alloc]initWithParameterArray:animParams andAnimPeriod:[[params objectAtIndex:1]floatValue]];
        }
    }else{
        NSArray *animParams = nil;
        if (params.count > 1) {
            animParams = [params subarrayWithRange:NSMakeRange(1, params.count-1)];
        }
        if([animVerb isEqualToString:@"depend"]){
            behavior = [[AnimationObjectDependency alloc]initWithParameterArray:animParams andAnimPeriod:0];
        }else if ([animVerb isEqualToString:@"reset_transform"]){
            behavior = [[ResetTransform alloc]initWithParameterArray:nil andAnimPeriod:0];
        }else if ([animVerb isEqualToString:@"replace"]){
            if (objectType == OBJECT_TYPE_IMAGE) {
                behavior = [[ReplaceImage alloc]initWithParameterArray:animParams andAnimPeriod:0];
            }else{
                
            }
        }else if ([animVerb isEqualToString:@"animate"] && objectType == OBJECT_TYPE_IMAGE){
            behavior = [[P2MSImageAnimationBehavior alloc]initWithParameterArray:animParams andAnimPeriod:0];
        }
    }

    return behavior;
}

@end
