//
//  P2MSAnimationObject.m
//  P2MSStoryboard
//
//  Created by PYAE PHYO MYINT SOE on 16/1/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "P2MSAnimationObject.h"
#import "P2MSObjectWrapper.h"
#import "P2MSObjectAnimationFactory.h"
#import "UIView+P2MSUIViewAnimation.h"
#import "NSObject+P2MSPerformSelector.h"
#import "P2MSObjectAnimationFactory.h"


@interface P2MSAnimationObject(){
    NSInteger curAnimationIndex;
    NSInteger curAnimateCount;
    NSInteger animationObjIndex;
    NSArray *curAnimationSequence;

    BOOL hasClickResponder, hasDragResponder, hasStopAnimationResponder;
    UIButton *invisibleButton;
    UIPanGestureRecognizer *gestureRecognizer;
    P2MSAnimation *animationObj, *curAnimationObj;
    
    CGPoint panGestureOrigin;
}
@property (nonatomic) CGRect initialRect;

@end

@implementation P2MSAnimationObject
@synthesize objectID;
@synthesize objectType;
@synthesize objectTag, isCancelled;
@synthesize view;

- (id)init{
    self = [super init];
    if (self) {
        self.objectID = [P2MSObjectWrapper generateUniqueID];
        self.objectType = OBJECT_TYPE_IMAGE;
        _objectBehaviors = [NSMutableArray array];
    }
    return self;
}

- (void)setupObjectType{
    view.userInteractionEnabled = !(_objectbehaviorType & OBJECT_BEHAVIOR_TYPE_DISABLED);
    if (_objectbehaviorType & OBJECT_BEHAVIOR_TYPE_TAP) {
        if (!invisibleButton) {
            invisibleButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [invisibleButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            invisibleButton.tag = view.tag;
            invisibleButton.frame = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height);
            [view addSubview:invisibleButton];
            hasClickResponder = [_delegate respondsToSelector:@selector(objectClicked:)];
        }
    }else if(invisibleButton){
        [invisibleButton removeFromSuperview];
        invisibleButton = nil;
    }
    if (_objectbehaviorType & OBJECT_BEHAVIOR_TYPE_DRAG) {
        if (!gestureRecognizer) {
            gestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(imagePanned:)];
            [view addGestureRecognizer:gestureRecognizer];
            hasDragResponder = [_delegate respondsToSelector:@selector(objectDragged:at:withGestureRecognizer:)];
        }
    }else if(gestureRecognizer){
        [view removeGestureRecognizer:gestureRecognizer];
        gestureRecognizer = nil;
    }
}

- (void)setObjectbehaviorType:(OBJECT_BEHAVIOR_TYPE)objectbehaviorType{
    _objectbehaviorType = objectbehaviorType;
    if (view) {
        [self setupObjectType];
    }
}

- (void)loadObject:(id)objectParams withAnimation:(id)animationParams associatedParentView:(UIView *)parentView withTag:(NSInteger)tagNumber initialParams:(NSString *)initParams{
    animationObj = (P2MSAnimation *)animationParams;
    curAnimationIndex = 0;
    curAnimateCount = 0;
    animationObjIndex = 0;
    self.objectTag = tagNumber;
    NSArray *arr = [initParams componentsSeparatedByString:@" "];
    _initialRect = [P2MSObjectWrapper getRectFromString:[arr objectAtIndex:1] withParentView:parentView];
    NSArray *imageNames = [P2MSObjectWrapper getNormalImages:[arr objectAtIndex:0]];
    if (self.view) {
        [view removeFromSuperview];
        [invisibleButton removeFromSuperview];
        invisibleButton = nil;
        [view removeGestureRecognizer:gestureRecognizer];
        gestureRecognizer = nil;
        view = nil;
    }
    view = [[UIImageView alloc]initWithFrame:_initialRect];
    if (arr.count>2) {
        view.alpha = [[arr objectAtIndex:2]floatValue];
    }
    if (imageNames.count > 1) {
        NSMutableArray *imgArray = [NSMutableArray arrayWithCapacity:imageNames.count];
        for (NSString *imgName in imageNames) {
            [imgArray addObject:[UIImage imageNamed:imgName]];
        }
        ((UIImageView *)view).animationImages = imgArray;
        CGFloat animationDuration = 1;
        CGFloat animationCount = CGFLOAT_MAX;
        if (arr.count > 3) {
            NSArray *duRepeat = [[arr objectAtIndex:3]componentsSeparatedByString:@","];
            if (duRepeat.count > 0) {
                animationDuration = [[duRepeat objectAtIndex:0]floatValue];
                if (duRepeat.count > 1) {
                    animationCount = [[duRepeat objectAtIndex:1]floatValue];
                    if (animationCount == 0) {
                        animationCount = CGFLOAT_MAX;
                    }
                }
            }
        }
        ((UIImageView *)view).animationDuration = animationDuration;
        ((UIImageView *)view).animationRepeatCount = animationCount;
        ((UIImageView *)view).image = [imgArray lastObject];
        [((UIImageView *)view) startAnimating];
    }else{
        [((UIImageView *)view) setImage:[UIImage imageNamed:[imageNames objectAtIndex:0]]];
    }
    view.tag = tagNumber;
    [parentView addSubview:view];
    [self setupObjectType];
}

- (void)setDelegate:(id)delegate{
    _delegate = delegate;
    hasDragResponder = [_delegate respondsToSelector:@selector(objectDragged:at:withGestureRecognizer:)];
    hasClickResponder = [_delegate respondsToSelector:@selector(objectClicked:)];
    hasStopAnimationResponder = [_delegate respondsToSelector:@selector(stoppedAnimationForObject:forAnimationIndex:)];
}

- (IBAction)buttonClicked:(id)sender{
    if (self.isCancelled) {
        return;
    }
    if (hasClickResponder) {
        [_delegate objectClicked:self];
    }
}

- (IBAction)imagePanned:(UIPanGestureRecognizer *)sender{
    if (self.isCancelled) {
        return;
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        panGestureOrigin = gestureRecognizer.view.frame.origin;
    }
    
    CGPoint translatedPoint = [gestureRecognizer translationInView:gestureRecognizer.view];
    CGPoint adjustedOrigin = panGestureOrigin;
    translatedPoint = CGPointMake(adjustedOrigin.x + translatedPoint.x, adjustedOrigin.y + translatedPoint.y);

    UIView *canvas = view.superview;
    translatedPoint.y = MAX(MIN(translatedPoint.y, canvas.bounds.size.height), 0);
    translatedPoint.x = MAX(MIN(translatedPoint.x, canvas.bounds.size.width), 0);
    
    UIView *paneView = gestureRecognizer.view;
    CGRect curRect = paneView.frame;
    curRect.origin.y = translatedPoint.y;
    curRect.origin.x = translatedPoint.x;
    paneView.frame = curRect;

    if (hasDragResponder) {
        [_delegate objectDragged:self at:translatedPoint withGestureRecognizer:sender];
    }
}


- (void)removeObject:(BOOL)keepAppearance{
    isCancelled = YES;
    if (_animationState == ANIMATION_STATE_ANIMATING || _animationState == ANIMATION_STATE_PAUSE) {
        [self stopTask:YES];
    }
    [invisibleButton removeFromSuperview];
    [gestureRecognizer removeTarget:self action:@selector(imagePanned:)];
    if (!keepAppearance) {
        [view removeFromSuperview];
    }
    view = nil;
    _delegate = nil;
}

- (void)stopTask:(BOOL)persistance{
    _animationState = ANIMATION_STATE_FINISHED;
    [view cancelAnimation:persistance];
    [self cancelAllSelectors];
}

- (void)pauseTask{
    if (_animationState == ANIMATION_STATE_FINISHED) {
        return;
    }
    _animationState = ANIMATION_STATE_PAUSE;
    [view pauseAnimation];
    [self pauseAllSelectors];
}

- (void)resumeTask{
    [view resumeAnimation];
    [self.selectors resumeAllSelectors];
    _animationState = ANIMATION_STATE_ANIMATING;
}

///////////////Animate String/////////////////

- (void)setAnimationString:(NSString *)animationString{
    if (animationString) {
        curAnimationSequence = [animationString componentsSeparatedByString:@"|"];
        curAnimationIndex = 0;
        [self animateForIndex:curAnimationIndex];
    }else{
        curAnimationIndex = -1;
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
    curAnimateCount = consecutiveAnims.count;
    for (NSString *animSequence in consecutiveAnims) {
        NSArray *animParts = [animSequence componentsSeparatedByString:@":"];
        NSArray *animParams = [[animParts objectAtIndex:1]componentsSeparatedByString:@","];
        CGFloat delay = [[animParams objectAtIndex:0]floatValue];
        if (delay) {
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
    animationObj.tempRepeatCount = animationObj.repeatCount;
    _animationState = ANIMATION_STATE_ANIMATING;
    if (animationObj.tempRepeatCount > 0) {
        [self animateChild:animationObj];
    }
}

///////////////Animate Object/////////////////

- (void)animateChild:(P2MSAnimation *)animObject{
    if (animObject.childAnimation.count) {
        P2MSAnimation *firstChild = [animObject.childAnimation firstObject];
        firstChild.tempRepeatCount = firstChild.tempRepeatCount;
        [self animateChild:firstChild];
    }else{
        curAnimationObj = animObject;
        curAnimationObj.tempRepeatCount = curAnimationObj.repeatCount;
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
        if ([_delegate respondsToSelector:@selector(animationDone:)]) {
            [_delegate animationDone:self];
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
    if (index >= curAnimationSequence.count){
        curAnimationObj.tempRepeatCount--;
        if (curAnimationObj.tempRepeatCount > 0) {
            [self setAnimationString:curAnimationObj.animationString];
        }else
            [self animateParent:curAnimationObj];
    }else{
        curAnimationIndex = index;
        [self animateForSequence:[curAnimationSequence objectAtIndex:index]];
    }
}

///////////////Animate Object/////////////////

#pragma mark P2MSObjectBehaviorDelegate
- (void)behaviorDone:(P2MSObjectBehavior *)behavior{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:curAnimationObj.serialIndex], @"animationSerialIndex", [NSNumber numberWithInteger:curAnimationIndex+1], @"animationIndex", [NSNumber numberWithInteger:view.tag], @"object_tag", nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:OBJECT_ANIMATION_DONE_NOTIFICATION object:nil userInfo:dict];
    curAnimateCount--;
    if (hasStopAnimationResponder) {
        [_delegate stoppedAnimationForObject:self forAnimationIndex:curAnimationIndex];
    }
    [_objectBehaviors removeObject:behavior];
    if (curAnimateCount <= 0) {
        [self animateForIndex:curAnimationIndex+1];
    }
}

@end
