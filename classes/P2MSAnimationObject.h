//
//  P2MSAnimationObject.h
//  P2MSStoryboard
//
//  Created by PYAE PHYO MYINT SOE on 16/1/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "P2MSObjectBehavior.h"


typedef enum {
    OBJECT_TYPE_DEFAULT,
    OBJECT_TYPE_DISABLED,
    OBJECT_TYPE_TAP,
    OBJECT_TYPE_DRAG
}OBJECT_TYPE;

@class P2MSAnimationObject;

@interface P2MSAnimation : NSObject
@property (nonatomic, retain) NSArray *childAnimation;
@property (nonatomic, retain) NSString *animationString;
@property (nonatomic) NSInteger repeatCount;
@property (nonatomic, weak) P2MSAnimation *parent;
@property (nonatomic) NSInteger childIndex;
@property (nonatomic) NSInteger tempRepeatCount;

+ (id)animationString:(NSString *)animString repeatCount:(NSInteger)repeatCount;
+ (id)animationWithChildAnimations:(NSArray *)childAnimation repeatCount:(NSInteger)repeatCount;

@end

@protocol P2MSAnimationObjectDelegate <NSObject>
@optional
- (void)stopAnimationForObject:(P2MSAnimationObject *)animatedObject forAnimationIndex:(NSInteger)index;
- (void)objectClicked:(P2MSAnimationObject *)animatedObject;
- (void)objectDragged:(P2MSAnimationObject *)animatedObject withGestureRecognizer:(UIPanGestureRecognizer *)gesture;
- (void)animationDone:(P2MSAnimationObject *)animatedObject;
@end

@interface P2MSAnimationObject : NSObject<P2MSObjectBehaviorDelegate>

@property (nonatomic, retain) NSMutableArray *objectBehaviors;

@property (nonatomic, retain) NSString *objectID;
@property (nonatomic, retain) UIImageView *imageObject;
@property (nonatomic, weak) id deleage;
@property (nonatomic) OBJECT_TYPE objectType;

- (void)loadObject:(P2MSAnimation *)animation inView:(UIView *)parentView withTag:(NSInteger)tagNumber rect:(CGRect)initialRect initParams:(NSString *)params;
- (void)removeObject;

- (void)startAnimation;
- (void)stopAnimation:(BOOL)keepLast;
- (void)pauseAnimation;
- (void)resumeAnimation;

@end
