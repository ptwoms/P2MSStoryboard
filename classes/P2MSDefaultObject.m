//
//  P2MSDefaultObject.m
//  P2MSStoryboard
//
//  Created by PYAE PHYO MYINT SOE on 8/2/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "P2MSDefaultObject.h"
#import "P2MSObjectWrapper.h"
#import "UIView+P2MSUIViewAnimation.h"
#import "NSObject+P2MSPerformSelector.h"
#import "P2MSObjectAnimationFactory.h"

@interface P2MSDefaultObject()

@property (nonatomic, retain)P2MSAnimation *animationObj, *curAnimationObj;
@property (nonatomic) NSInteger curAnimationIndex, curAnimateCount, animationObjIndex;
@property (nonatomic, retain)NSArray *curAnimationSequence;
@property (nonatomic) BOOL hasDragResponder, hasClickResponder, hasStopAnimationResponder;


@end

@implementation P2MSDefaultObject
@synthesize objectID, objectTag, objectType;
@synthesize view;
@synthesize isCancelled;

- (id)init{
    self = [super init];
    if (self) {
        self.objectID = [P2MSObjectWrapper generateUniqueID];
        self.objectType = OBJECT_TYPE_IMAGE;
        _objectBehaviors = [NSMutableArray array];
    }
    return self;
}

//required to overwrite by the subclass
- (void)setupObjectType{
    self.view.userInteractionEnabled = !(_objectbehaviorType & OBJECT_BEHAVIOR_TYPE_DISABLED);
}

- (void)setObjectbehaviorType:(OBJECT_BEHAVIOR_TYPE)objectbehaviorType{
    _objectbehaviorType = objectbehaviorType;
    if (self.view) {
        [self setupObjectType];
    }
}

- (void)loadObject:(id)objectParams withAnimation:(id)animationParams associatedParentView:(UIView *)parentView withTag:(NSInteger)tagNumber initialParams:(NSString *)initParams{
    _animationObj = (P2MSAnimation *)animationParams;
    _curAnimationIndex = 0;
    _curAnimateCount = 0;
    _animationObjIndex = 0;
    self.objectTag = tagNumber;
}

- (void)setDelegate:(id)delegate{
    _delegate = delegate;
    _hasDragResponder = [_delegate respondsToSelector:@selector(objectDragged:at:withGestureRecognizer:)];
    _hasClickResponder = [_delegate respondsToSelector:@selector(objectClicked:)];
    _hasStopAnimationResponder = [_delegate respondsToSelector:@selector(stoppedAnimationForObject:forAnimationIndex:)];
}


- (void)removeObject:(BOOL)keepAppearance{
    isCancelled = YES;
    if (_animationState == ANIMATION_STATE_ANIMATING || _animationState == ANIMATION_STATE_PAUSE) {
        [self stopTask:YES];
    }
    if (!keepAppearance) {
        [view removeFromSuperview];
    }
    self.view = nil;
    self.delegate = nil;
}

- (void)stopTask:(BOOL)persistance{
    _animationState = ANIMATION_STATE_FINISHED;
    [self.view cancelAnimation:persistance];
    [self cancelAllSelectors];
}

- (void)pauseTask{
    if (_animationState == ANIMATION_STATE_FINISHED) {
        return;
    }
    _animationState = ANIMATION_STATE_PAUSE;
    [self.view pauseAnimation];
    [self pauseAllSelectors];
}

- (void)resumeTask{
    [self.view resumeAnimation];
    [self.selectors resumeAllSelectors];
    _animationState = ANIMATION_STATE_ANIMATING;
}

///////////////Animate String/////////////////

- (void)setAnimationString:(NSString *)animationString{
    if (animationString) {
        _curAnimationSequence = [animationString componentsSeparatedByString:@"|"];
        _curAnimationIndex = 0;
        [self animateForIndex:_curAnimationIndex];
    }else{
        _curAnimationIndex = -1;
    }
}

- (void)performAnimationForVerb:(NSString *)animVerb andAnimParams:(NSArray *)animParams{
    id<P2MSObjectBehavior> objectBehavior = [P2MSObjectAnimationFactory getBehaviorFromVerb:animVerb andParams:animParams];
    objectBehavior.delegate = self;
    [objectBehavior performBehaviorOnObject:self];
    [_objectBehaviors addObject:objectBehavior];
}

- (void)animateForSequence:(NSString *)animSequence{
    NSArray *consecutiveAnims = [animSequence componentsSeparatedByString:@"--"];
    _curAnimateCount = consecutiveAnims.count;
    for (NSString *animSequence in consecutiveAnims) {
        NSArray *animParts = [animSequence componentsSeparatedByString:@":"];
        NSArray *animParams = [[animParts objectAtIndex:1]componentsSeparatedByString:@","];
        CGFloat delay = [[animParams objectAtIndex:0]floatValue];
        if (delay) {
            NSLog(@"Perform P2MSSelector is called");
            [self performP2MSSelector:@selector(delayedAnimatoinSequence:) withObject:animParts afterDelay:delay];
        }else{
            NSString *animVerb = [animParts objectAtIndex:0];
            [self performAnimationForVerb:animVerb andAnimParams:animParams];
        }
    }
}

- (void)delayedAnimatoinSequence:(NSArray *)animParts{
    NSArray *animParams = [[animParts objectAtIndex:1]componentsSeparatedByString:@","];
    NSString *animVerb = [animParts objectAtIndex:0];
    [self performAnimationForVerb:animVerb andAnimParams:animParams];
}

///////////////Animate String/////////////////

- (void)startTask{
    _animationObj.tempRepeatCount = (_animationObj.repeatCount==0)?CGFLOAT_MAX:_animationObj.repeatCount;
    _animationState = ANIMATION_STATE_ANIMATING;
    if (_animationObj.tempRepeatCount > 0) {
        [self animateChild:_animationObj];
    }
}

///////////////Animate Object/////////////////

- (void)animateChild:(P2MSAnimation *)animObject{
    if (animObject.childAnimation.count) {
        P2MSAnimation *firstChild = [animObject.childAnimation firstObject];
        firstChild.tempRepeatCount = (firstChild.repeatCount==0)?CGFLOAT_MAX:firstChild.repeatCount;
        [self animateChild:firstChild];
    }else{
        _curAnimationObj = animObject;
        _curAnimationObj.tempRepeatCount = (_curAnimationObj.repeatCount==0)?CGFLOAT_MAX:_curAnimationObj.repeatCount;
        [self setAnimationString:animObject.animationString];
    }
}

- (void)dealloc{
    NSLog(@"Animation object dealloc %@ %d", self.objectID, _animationState);
}

- (void)animateParent:(P2MSAnimation *)animation{
    P2MSAnimation *parent = animation.parent;
    if (parent) {
        if (animation.childIndex+1 < parent.childAnimation.count) {
            P2MSAnimation *nextChild = [parent.childAnimation objectAtIndex:animation.childIndex+1];
            [self animateChild:nextChild];
        }else{
            [self animateNext:parent];
        }
    }else{
        _animationState = ANIMATION_STATE_FINISHED;
        if ([self.delegate respondsToSelector:@selector(animationDone:)]) {
            [self.delegate animationDone:self];
        }
    }
}

- (void)animateNext:(P2MSAnimation *)animation{
    animation.tempRepeatCount--;
    if (animation.tempRepeatCount > 0) {
        [self animateChild:animation];
    }else{
        [self animateParent:animation];
    }
}

- (void)animateForIndex:(NSInteger) index{
    if (index >= _curAnimationSequence.count){
        _curAnimationObj.tempRepeatCount--;
        if (_curAnimationObj.tempRepeatCount > 0) {
            [self setAnimationString:_curAnimationObj.animationString];
        }else
            [self animateParent:_curAnimationObj];
    }else{
        _curAnimationIndex = index;
        [self animateForSequence:[_curAnimationSequence objectAtIndex:index]];
    }
}

///////////////Animate Object/////////////////

#pragma mark P2MSObjectBehaviorDelegate
- (void)behaviorDone:(P2MSObjectBehavior *)behavior{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:_curAnimationObj.serialIndex], @"animationSerialIndex", [NSNumber numberWithInteger:_curAnimationIndex+1], @"animationIndex", [NSNumber numberWithInteger:self.view.tag], @"object_tag", nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:OBJECT_ANIMATION_DONE_NOTIFICATION object:nil userInfo:dict];
    _curAnimateCount--;
    if (_hasStopAnimationResponder) {
        [self.delegate stoppedAnimationForObject:self forAnimationIndex:_curAnimationIndex];
    }
    [_objectBehaviors removeObject:behavior];
    if (_curAnimateCount <= 0) {
        [self animateForIndex:_curAnimationIndex+1];
    }
}


@end
