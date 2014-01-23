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
	

@implementation P2MSAnimation

+ (id)animationString:(NSString *)animString repeatCount:(NSInteger)repeatCount{
    P2MSAnimation *animation = [[P2MSAnimation alloc]init];
    animation.repeatCount = (repeatCount == 0)?CGFLOAT_MAX:repeatCount;
    animation.animationString = animString;
    return animation;
}

+ (id)animationWithChildAnimations:(NSArray *)childAnimation repeatCount:(NSInteger)repeatCount{
    P2MSAnimation *animation = [[P2MSAnimation alloc]init];
    animation.repeatCount = (repeatCount == 0)?CGFLOAT_MAX:repeatCount;
    int i = 0;
    for (P2MSAnimation *anim in childAnimation) {
        anim.childIndex = i++;
        anim.parent = animation;
    }
    animation.childAnimation = childAnimation;
    return animation;
}

@end


@interface P2MSAnimationObject(){
    NSInteger curAnimationIndex;
    NSInteger curAnimateCount;
    NSInteger animationObjIndex;
    NSArray *curAnimationSequence;

    BOOL hasClickResponder, hasDragResponder, hasStopAnimationResponder;
    UIButton *invisibleButton;
    UIPanGestureRecognizer *gestureRecognizer;
    P2MSAnimation *animationObj, *curAnimationObj;
}
@property (nonatomic) CGRect initialRect;
//@property (nonatomic, retain) NSString *animationString;

@end

@implementation P2MSAnimationObject

- (id)init{
    self = [super init];
    if (self) {
        self.objectID = [P2MSObjectWrapper generateUniqueID];
        self.objectType = OBJECT_TYPE_DEFAULT;
        _objectBehaviors = [NSMutableArray array];
    }
    return self;
}

- (void)setupObjectType{
    _imageObject.userInteractionEnabled = !(_objectType & OBJECT_TYPE_DISABLED);
    if (_objectType & OBJECT_TYPE_TAP) {
        if (!invisibleButton) {
            invisibleButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [invisibleButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            invisibleButton.tag = _imageObject.tag;
            invisibleButton.frame = CGRectMake(0, 0, _imageObject.bounds.size.width, _imageObject.bounds.size.height);
            [_imageObject addSubview:invisibleButton];
        }
    }else if(invisibleButton){
        [invisibleButton removeFromSuperview];
        invisibleButton = nil;
    }
    if (_objectType & OBJECT_TYPE_DRAG) {
        if (!gestureRecognizer) {
            gestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(imagePanned:)];
            [_imageObject addGestureRecognizer:gestureRecognizer];
        }
    }else if(gestureRecognizer){
        [_imageObject removeGestureRecognizer:gestureRecognizer];
        gestureRecognizer = nil;
    }
}

- (void)setObjectType:(OBJECT_TYPE)objectType{
    _objectType = objectType;
    if (_imageObject) {
        [self setupObjectType];
    }
}

- (void)loadObject:(P2MSAnimation *)animation inView:(UIView *)parentView withTag:(NSInteger)tagNumber rect:(CGRect)initialRect initParams:(NSString *)params{
    animationObj = animation;
    curAnimationIndex = 0;
    curAnimateCount = 0;
    animationObjIndex = 0;
    _initialRect = initialRect;
    NSArray *arr = [params componentsSeparatedByString:@" "];
    NSArray *imageNames = [P2MSObjectWrapper getNormalImages:[arr objectAtIndex:0]];
    if (_imageObject) {
        [_imageObject removeFromSuperview];
        [invisibleButton removeFromSuperview];
        invisibleButton = nil;
        [_imageObject removeGestureRecognizer:gestureRecognizer];
        gestureRecognizer = nil;
        _imageObject = nil;
    }
    _imageObject = [[UIImageView alloc]initWithFrame:_initialRect];
    if (arr.count>1) {
        _imageObject.alpha = [[arr objectAtIndex:1]floatValue];
    }
    if (imageNames.count > 1) {
        NSMutableArray *imgArray = [NSMutableArray arrayWithCapacity:imageNames.count];
        for (NSString *imgName in imageNames) {
            [imgArray addObject:[UIImage imageNamed:imgName]];
        }
        _imageObject.animationImages = imgArray;
        CGFloat animationDuration = 1;
        CGFloat animationCount = CGFLOAT_MAX;
        if (arr.count > 2) {
            NSArray *duRepeat = [[arr objectAtIndex:2]componentsSeparatedByString:@","];
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
        _imageObject.animationDuration = animationDuration;
        _imageObject.animationRepeatCount = animationCount;
        _imageObject.image = [imgArray lastObject];
        [_imageObject startAnimating];
    }else{
        [_imageObject setImage:[UIImage imageNamed:[imageNames objectAtIndex:0]]];
    }
    _imageObject.tag = tagNumber;
    [parentView addSubview:_imageObject];
    [self setupObjectType];
}

- (void)setDeleage:(id)deleage{
    _deleage = deleage;
    hasDragResponder = [_deleage respondsToSelector:@selector(objectDragged:withGestureRecognizer:)];
    hasClickResponder = [_deleage respondsToSelector:@selector(objectClicked:)];
    hasStopAnimationResponder = [_deleage respondsToSelector:@selector(stopAnimationForObject:forAnimationIndex:)];
}

- (IBAction)buttonClicked:(id)sender{
    if (hasClickResponder) {
        [_deleage objectClicked:self];
    }
}

- (IBAction)imagePanned:(UIPanGestureRecognizer *)sender{
    if (hasDragResponder) {
        [_deleage objectDragged:self withGestureRecognizer:sender];
    }
}

//Haven't Implemented
- (void)removeObject{
    [_imageObject removeFromSuperview];
    _imageObject = nil;
    _deleage = nil;
}

//Haven't Implemented
- (void)stopAnimation:(BOOL)keepLast{
//    [_imageObject cancelAnimation:keepLast];
}

//Haven't Implemented
- (void)pauseAnimation{
//    [_imageObject pauseAnimation];
}

//Haven't Implemented
- (void)resumeAnimation{
//    [_imageObject resumeAnimation];
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

- (void)startAnimation{
    animationObj.tempRepeatCount = animationObj.repeatCount;
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
    NSLog(@"Animation object dealloc %@", self.objectID);
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
        if ([_deleage respondsToSelector:@selector(animationDone:)]) {
            [_deleage animationDone:self];
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
    curAnimateCount--;
    if (hasStopAnimationResponder) {
        [_deleage stopAnimationForObject:self forAnimationIndex:curAnimationIndex];
    }
    [_objectBehaviors removeObject:behavior];
    if (curAnimateCount <= 0) {
        [self animateForIndex:curAnimationIndex+1];
    }
}

@end
