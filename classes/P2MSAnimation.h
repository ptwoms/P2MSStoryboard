//
//  P2MSAnimation.h
//  P2MSStoryboard
//
//  Created by PYAE PHYO MYINT SOE on 8/2/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    OBJECT_BEHAVIOR_TYPE_DEFAULT,
    OBJECT_BEHAVIOR_TYPE_DISABLED,
    OBJECT_BEHAVIOR_TYPE_BUTTON = 2,
    OBJECT_BEHAVIOR_TYPE_DRAG = 4
}OBJECT_BEHAVIOR_TYPE;

typedef enum {
    ANIMATION_STATE_NOT_STARTED,
    ANIMATION_STATE_ANIMATING,
    ANIMATION_STATE_PAUSE,
    ANIMATION_STATE_FINISHED
}ANIMATION_STATE;


@interface P2MSAnimation : NSObject
@property (nonatomic, retain) NSArray *childAnimation;
@property (nonatomic, retain) NSString *animationString;
@property (nonatomic) CGFloat repeatCount;
@property (nonatomic) NSInteger serialIndex;
@property (nonatomic, unsafe_unretained) P2MSAnimation *parent;
@property (nonatomic) NSInteger childIndex;
@property (nonatomic) CGFloat tempRepeatCount;

+ (id)animationString:(NSString *)animString repeatCount:(CGFloat)repeatCount serialIndex:(NSInteger)serialIndex;
+ (id)animationWithChildAnimations:(NSArray *)childAnimation repeatCount:(CGFloat)repeatCount serialStartIndex:(NSInteger)serialStartIndex;
+ (id)animationFromString:(NSString *)stringRep;


@end