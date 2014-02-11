//
//  P2MSDefaultObject.h
//  P2MSStoryboard
//
//  Created by PYAE PHYO MYINT SOE on 8/2/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "P2MSAbstractObject.h"
#import "P2MSAnimation.h"
#import "P2MSObjectBehavior.h"

@class P2MSDefaultObject;

@protocol P2MSDefaultObjectDelegate <NSObject>
@optional
- (void)stoppedAnimationForObject:(P2MSDefaultObject *)animatedObject forAnimationIndex:(NSInteger)index;
- (void)objectClicked:(P2MSDefaultObject *)animatedObject;
- (void)objectDragged:(P2MSDefaultObject *)animatedObject at:(CGPoint)curPosition withGestureRecognizer:(UIPanGestureRecognizer *)gesture;
- (void)animationDone:(P2MSDefaultObject *)animatedObject;
@end


@interface P2MSDefaultObject : NSObject<P2MSAbstractObject, P2MSObjectBehaviorDelegate>

@property (nonatomic, readonly) ANIMATION_STATE animationState;
@property (nonatomic, retain) NSMutableArray *objectBehaviors;
@property (nonatomic, unsafe_unretained) id<P2MSDefaultObjectDelegate> delegate;
@property (nonatomic) OBJECT_BEHAVIOR_TYPE objectbehaviorType;

- (void)setupObjectType;

@end
