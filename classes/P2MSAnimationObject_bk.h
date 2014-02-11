//
//  P2MSAnimationObject.h
//  P2MSStoryboard
//
//  Created by PYAE PHYO MYINT SOE on 16/1/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "P2MSObjectBehavior.h"
#import "P2MSAbstractObject.h"
#import "P2MSAnimation.h"

@protocol P2MSAnimationObjectDelegate <NSObject>
@optional
- (void)stoppedAnimationForObject:(P2MSAnimationObject *)animatedObject forAnimationIndex:(NSInteger)index;
- (void)objectClicked:(P2MSAnimationObject *)animatedObject;
- (void)objectDragged:(P2MSAnimationObject *)animatedObject at:(CGPoint)curPosition withGestureRecognizer:(UIPanGestureRecognizer *)gesture;
- (void)animationDone:(P2MSAnimationObject *)animatedObject;
@end

@interface P2MSAnimationObject : NSObject<P2MSAbstractObject, P2MSObjectBehaviorDelegate>

@property (nonatomic, retain) NSMutableArray *objectBehaviors;
@property (nonatomic, readonly) ANIMATION_STATE animationState;

@property (nonatomic, weak) id delegate;
@property (nonatomic) OBJECT_BEHAVIOR_TYPE objectbehaviorType;

@end
