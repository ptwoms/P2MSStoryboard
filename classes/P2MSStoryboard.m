//
//  P2MSStoryboard.m
//  P2MSStoryboard
//
//  Created by PYAE PHYO MYINT SOE on 3/2/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "P2MSStoryboard.h"
#import "P2MSScene.h"

@interface P2MSStoryboard(){
    NSArray *scenes;
    P2MSScene *tempScene;
}
@property (nonatomic, retain) P2MSScene *curScene;

@end

@implementation P2MSStoryboard

- (void)loadScenesFromFilePath:(NSString *)filePath{
    NSError *error;
    NSString *animRawString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    NSString *animString =  [animRawString stringByReplacingOccurrencesOfString:@"//.*\n" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, animRawString.length)];
    scenes = [animString componentsSeparatedByString:@"\n##\n"];
    _totalScenes = scenes.count;
}

- (void)startReading{
    if (self.superview) {
        _curSceneIndex = 0;
        [self displaySceneForIndex:_curSceneIndex];
    }
}

- (void)displaySceneForIndex:(NSInteger)index{
    if (index < scenes.count) {
        _curSceneIndex = index;
        if (tempScene) {
            [tempScene stopAnimation];
            tempScene = nil;
        }
        tempScene = [P2MSScene loadScene:[scenes objectAtIndex:index] inRect:self.bounds withTag:index andObjectDelegate:self];
        [self addSubview:tempScene];
        if (_curScene) {
            [_curScene stopAnimation];
            [self performTransitionOnView:tempScene andNextView:_curScene animType:kCATransitionFade subType:kCATransitionFade];
            if ([_delegate respondsToSelector:@selector(changedToScene:)]) {
                [_delegate changedToScene:_curSceneIndex+1];
            }
        }else{
            _curScene = tempScene;
            [tempScene startAnimation];
        }
    }
}

- (void)performTransitionOnView:(UIView *)viewOne andNextView:(UIView *)viewTwo animType:(NSString *)animType subType:(NSString *)animSubType{
    if ([animType isEqualToString:kCATransitionFade]) {
        tempScene.hidden = YES;
        CATransition* transition = [CATransition animation];
        transition.delegate = self;
        transition.type = animType;
        transition.duration = 1.25;
        [self.layer addAnimation:transition forKey:@"transition"];
        viewTwo.hidden = YES;
        viewOne.hidden = NO;
    }else{
        CATransition* transition = [CATransition animation];
        transition.startProgress = 1.0;
        transition.delegate = self;
        transition.endProgress = 0.0;
        transition.type = animType;
        transition.subtype = animSubType;
        transition.duration = 1.25;
        [viewOne.layer addAnimation:transition forKey:@"transition"];
        [viewTwo.layer addAnimation:transition forKey:@"transition"];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (tempScene) {
        _curScene = tempScene;
        tempScene = nil;
        [_curScene startAnimation];
    }
}

- (void)previousScene{
    if (_curSceneIndex > 0) {
        [self displaySceneForIndex:_curSceneIndex-1];
    }
}

- (void)nextScene{
    if (_curSceneIndex < _totalScenes-1) {
        [self displaySceneForIndex:_curSceneIndex+1];
    }
}

- (void)animationDone:(P2MSAnimationObject *)animatedObject{
    //remove the inactive animation object from the memory
    if (animatedObject.objectbehaviorType == OBJECT_BEHAVIOR_TYPE_DISABLED || animatedObject.objectbehaviorType == OBJECT_BEHAVIOR_TYPE_DEFAULT ) {
        [_curScene.objectsInScene removeObject:animatedObject];
    }
}

- (void)objectClicked:(P2MSAnimationObject *)animatedObject{
    if ([_delegate respondsToSelector:@selector(clickedObject:forSceneIndex:)]) {
        [_delegate clickedObject:animatedObject forSceneIndex:_curSceneIndex+1];
    }
}

- (void)objectDragged:(P2MSAnimationObject *)animatedObject at:(CGPoint)curPos withGestureRecognizer:(UIPanGestureRecognizer *)gesture{
    if ([_delegate respondsToSelector:@selector(draggedObject:at:withGestureRecognizer:forSceneIndex:)]) {
        [_delegate draggedObject:animatedObject at:curPos withGestureRecognizer:gesture forSceneIndex:_curSceneIndex+1];
    }
}

@end
