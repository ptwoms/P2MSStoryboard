//
//  P2MSAnimationObject.m
//  P2MSStoryboard
//
//  Created by PYAE PHYO MYINT SOE on 16/1/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "P2MSAnimationObject.h"
#import "P2MSObjectWrapper.h"
#import "P2MSDefaultObjectSubClass.h"


@interface P2MSAnimationObject(){
    UIButton *invisibleButton;
    UIPanGestureRecognizer *gestureRecognizer;
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
        self.objectBehaviors = [NSMutableArray array];
    }
    return self;
}

- (void)setupObjectType{
    view.userInteractionEnabled = !(self.objectbehaviorType & OBJECT_BEHAVIOR_TYPE_DISABLED);
    if (self.objectbehaviorType & OBJECT_BEHAVIOR_TYPE_BUTTON) {
        if (!invisibleButton) {
            invisibleButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [invisibleButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            invisibleButton.tag = view.tag;
            invisibleButton.frame = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height);
            [view addSubview:invisibleButton];
            self.hasClickResponder = [self.delegate respondsToSelector:@selector(objectClicked:)];
        }
    }else if(invisibleButton){
        [invisibleButton removeFromSuperview];
        invisibleButton = nil;
    }
    if (self.objectbehaviorType & OBJECT_BEHAVIOR_TYPE_DRAG) {
        if (!gestureRecognizer) {
            gestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(imagePanned:)];
            [view addGestureRecognizer:gestureRecognizer];
            self.hasDragResponder = [self.delegate respondsToSelector:@selector(objectDragged:at:withGestureRecognizer:)];
        }
    }else if(gestureRecognizer){
        [view removeGestureRecognizer:gestureRecognizer];
        gestureRecognizer = nil;
    }
}

- (void)loadObject:(id)objectParams withAnimation:(id)animationParams associatedParentView:(UIView *)parentView withTag:(NSInteger)tagNumber initialParams:(NSString *)initParams{
    [super loadObject:objectParams withAnimation:animationParams associatedParentView:parentView withTag:tagNumber initialParams:initParams];
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
    
    NSArray *alphaDuration = nil;
    if (arr.count>2) {
        alphaDuration = [[arr objectAtIndex:2]componentsSeparatedByString:@","];
        view.alpha = [[alphaDuration objectAtIndex:0]floatValue];
    }
    if (imageNames.count > 1) {
        NSMutableArray *imgArray = [NSMutableArray arrayWithCapacity:imageNames.count];
        for (NSString *imgName in imageNames) {
            [imgArray addObject:[UIImage imageNamed:imgName]];
        }
        ((UIImageView *)view).animationImages = imgArray;
        CGFloat animationDuration = 1;
        CGFloat animationCount = CGFLOAT_MAX;
        if (alphaDuration.count > 1) {
            animationDuration = [[alphaDuration objectAtIndex:1]floatValue];
            if (alphaDuration.count > 2) {
                animationCount = [[alphaDuration objectAtIndex:2]floatValue];
                if (animationCount == 0) {
                    animationCount = CGFLOAT_MAX;
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

- (IBAction)buttonClicked:(id)sender{
    if (self.isCancelled) {
        return;
    }
    if (self.hasClickResponder) {
        [self.delegate objectClicked:self];
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
    if (self.hasDragResponder) {
        [self.delegate objectDragged:self at:translatedPoint withGestureRecognizer:sender];
    }
}

- (void)removeObject:(BOOL)keepAppearance{
    [super removeObject:keepAppearance];
    [invisibleButton removeFromSuperview];
    [gestureRecognizer removeTarget:self action:@selector(imagePanned:)];
}

@end
