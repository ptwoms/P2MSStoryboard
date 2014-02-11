//
//  P2MSAbstractObject.h
//  P2MSStoryboard
//
//  Created by PYAE PHYO MYINT SOE on 5/2/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    OBJECT_TYPE_IMAGE,
    OBJECT_TYPE_TEXT,
    OBJECT_TYPE_AUDIO,
}OBJECT_TYPE;


#define OBJECT_ANIMATION_DONE_NOTIFICATION @"object_animation_done"

@protocol P2MSAbstractObject <NSObject>

@property (nonatomic, retain) NSString *objectID;
@property (nonatomic) OBJECT_TYPE objectType;
@property (nonatomic) NSInteger objectTag;
@property (nonatomic, readonly) BOOL isCancelled;
@property (nonatomic, retain) UIView *view;


- (void)loadObject:(id)objectParams withAnimation:(id)animationParams associatedParentView:(UIView *)parentView withTag:(NSInteger)tagNumber initialParams:(NSString *)initParams;
- (void)removeObject:(BOOL)keepAppearance;

//- (void)moveObjectToPosition:(CGPoint)finalPoint duration:(CGFloat)duration;

- (void)startTask;
- (void)stopTask:(BOOL)persistance;
- (void)pauseTask;
- (void)resumeTask;

@end
