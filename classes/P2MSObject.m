//
//  P2MSObject.m
//  P2MSStoryboard
//
//  Created by PYAE PHYO MYINT SOE on 21/12/13.
//  Copyright (c) 2013 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "P2MSObject.h"
#import "P2MSObjectWrapper.h"

@interface P2MSObject(){
    NSInteger curAnimationIndex;
    NSInteger curAnimateCount;
    NSArray *animSequences;
    
    BOOL hasClickResponder, hasDragResponder, hasStopAnimationResponder;
}

@end

@implementation P2MSObject

- (id)init{
    self = [super init];
    if (self) {
        self.objectID = [P2MSObjectWrapper generateUniqueID];
    }
    return self;
}

- (void)loadObject:(NSString *)objectString inView:(UIView *)parentView withTag:(NSInteger)tagNumber{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@" +" options:NSRegularExpressionCaseInsensitive error:NULL];
    objectString = [regex stringByReplacingMatchesInString:objectString options:0 range:NSMakeRange(0, [objectString length]) withTemplate:@" "];
    
    NSRegularExpression *regex1 = [NSRegularExpression regularExpressionWithPattern:@" *, +" options:NSRegularExpressionCaseInsensitive error:NULL];
    objectString = [regex1 stringByReplacingMatchesInString:objectString options:0 range:NSMakeRange(0, [objectString length]) withTemplate:@","];
    
    NSArray *imgProperties = [objectString componentsSeparatedByString:@" "];
    NSString *imgType = [imgProperties objectAtIndex:0];
    NSArray *imageNames = [P2MSObjectWrapper getNormalImages:[imgProperties objectAtIndex:1]];
    CGRect imgRect = [P2MSObjectWrapper getRectFromPoint:[imgProperties objectAtIndex:3] andSize:[imgProperties objectAtIndex:2] withParentView:parentView];
    
    if (_animateObject) {
        [_animateObject removeFromSuperview];
        _animateObject = nil;
    }
    
    _animateObject = [[UIImageView alloc]initWithFrame:imgRect];
    NSArray *alphaAndImgAnim = [[imgProperties objectAtIndex:4] componentsSeparatedByString:@","];
    _animateObject.alpha = [[alphaAndImgAnim objectAtIndex:0]floatValue];
    if (imageNames.count > 1) {
        NSMutableArray *imgArray = [NSMutableArray arrayWithCapacity:imageNames.count];
        for (NSString *imgName in imageNames) {
            [imgArray addObject:[UIImage imageNamed:imgName]];
        }
        _animateObject.animationImages = imgArray;
        CGFloat animationDuration = [[alphaAndImgAnim objectAtIndex:1] floatValue];
        CGFloat animationCount = [[alphaAndImgAnim objectAtIndex:2] floatValue];
        _animateObject.animationDuration = animationDuration;
        _animateObject.animationRepeatCount = (animationCount == 0)?CGFLOAT_MAX:animationCount;
        _animateObject.image = [imgArray lastObject];
        [_animateObject startAnimating];
    }else{
        [_animateObject setImage:[UIImage imageNamed:[imageNames objectAtIndex:0]]];
    }
    _animateObject.userInteractionEnabled = YES;
    _animateObject.tag = tagNumber;
    [parentView addSubview:_animateObject];
    
    if ([imgType rangeOfString:@"disabled"].length != 0) {
        _animateObject.userInteractionEnabled = NO;
    }
    if ([imgType rangeOfString:@"tap"].length != 0) {
        UIButton *invisibleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [invisibleBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        invisibleBtn.tag = tagNumber;
        invisibleBtn.frame = CGRectMake(0, 0, _animateObject.frame.size.width, _animateObject.frame.size.height);
        [_animateObject addSubview:invisibleBtn];
    }
    if ([imgType rangeOfString:@"drag"].length != 0) {
        UIPanGestureRecognizer *gestureRecog = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(imagePanned:)];
        [_animateObject addGestureRecognizer:gestureRecog];
    }

    if (imgProperties.count > 5) {
        self.animationString = [imgProperties objectAtIndex:5];
    }
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

- (void)removeObject{
    [_animateObject removeFromSuperview];
    _animateObject = nil;
    animSequences = nil;
    _animationString = nil;
    _deleage = nil;
}

- (void)setAnimationString:(NSString *)animationString{
    if (animationString) {
        animSequences = [animationString componentsSeparatedByString:@"|"];
        curAnimationIndex = 0;
        [self animateForIndex:curAnimationIndex];
    }else{
        animSequences = nil;
        curAnimationIndex = -1;
    }
}

- (void)animateForIndex:(NSInteger) index{
    if (index >= animSequences.count)return;
    curAnimationIndex = index;
    [self animateForSequence:[animSequences objectAtIndex:index]];
}

- (void)animateForSequence:(NSString *)animSequence{
    NSArray *consecutiveAnims = [animSequence componentsSeparatedByString:@"--"];
    for (NSString *animSequence in consecutiveAnims) {
        NSArray *animParts = [animSequence componentsSeparatedByString:@":"];
        NSArray *animParams = [[animParts objectAtIndex:1]componentsSeparatedByString:@","];
        CGFloat delay = [[animParams objectAtIndex:0]floatValue];
        if (delay) {
            [self performSelector:@selector(delayedAnimatoinSequence:) withObject:animSequence afterDelay:delay];
        }else{
            NSString *animVerb = [animParts objectAtIndex:0];
            [self performAnimationForVerb:animVerb andAnimParams:animParams];
        }
    }
}

- (void)dealloc{
    NSLog(@"Dealloc is called for object ID %@", self.objectID);
}

- (void)performAnimationForVerb:(NSString *)animVerb andAnimParams:(NSArray *)animParams{
    if ([animVerb isEqualToString:@"remove"]) {
        [self removeObject];
    }else{
        CGFloat animPeriod = [[animParams objectAtIndex:1]floatValue];
        BOOL isMove = NO;
        void (^animationBlock)();
        curAnimateCount++;
        if ([animVerb isEqualToString:@"alpha"]) {
            CGFloat finalAlpha = [[animParams objectAtIndex:2]floatValue];
            animationBlock = ^void(){
                _animateObject.alpha = finalAlpha;
            };
//            [animationObject startAnimating];
        }else if ([animVerb isEqualToString:@"move"]){
            CGRect finalRect = [_animateObject bounds];            
            finalRect.origin.x = [P2MSObjectWrapper getPosFromString:[animParams objectAtIndex:2] withParentView:_animateObject.superview];
            finalRect.origin.y = [P2MSObjectWrapper getPosFromString:[animParams objectAtIndex:3] withParentView:_animateObject.superview];

            CGPoint newCenter = CGPointMake(finalRect.origin.x + (finalRect.size.width/2), finalRect.origin.y + (finalRect.size.height/2));
            
            animationBlock = ^void(){
                _animateObject.center =  newCenter;
            };
            isMove = YES;
            [_animateObject startAnimating];
        }else if([animVerb isEqualToString:@"move_scale"]){
            CGRect finalRec = CGRectMake([[animParams objectAtIndex:2]floatValue], [[animParams objectAtIndex:3]floatValue], [[animParams objectAtIndex:4]floatValue], [[animParams objectAtIndex:5]floatValue]);
            animationBlock = ^void(){
                _animateObject.frame = finalRec;
            };
            isMove = YES;
            [_animateObject startAnimating];
        }else if ([animVerb isEqualToString:@"rotate"]){
            CGFloat degree = [[animParams objectAtIndex:2]floatValue];
            animationBlock = ^void(){
                _animateObject.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(degree));
            };
        }else if ([animVerb isEqualToString:@"flip_rotate"]){
            CGFloat horX = [[animParams objectAtIndex:2]floatValue];
            CGFloat verY = [[animParams objectAtIndex:3]floatValue];
            CGFloat degree = [[animParams objectAtIndex:4]floatValue];
            animationBlock = ^void(){
                CGAffineTransform trans = CGAffineTransformMakeScale(horX, verY);
                _animateObject.transform = CGAffineTransformRotate(trans, DEGREES_TO_RADIANS(degree));
            };
        }else if ([animVerb isEqualToString:@"clock_rotate"]){
            CGFloat repeatCount = [[animParams objectAtIndex:2]floatValue];
            CALayer *layer = _animateObject.layer;
            CAKeyframeAnimation *animation;
            animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
            animation.duration = animPeriod;
            animation.cumulative = YES;
            animation.additive = YES;
            animation.calculationMode = kCAAnimationDiscrete;
            animation.repeatCount = (repeatCount>0)?repeatCount:CGFLOAT_MAX;
            NSMutableArray *animationValues = [NSMutableArray array];
            NSMutableArray *animationTimes = [NSMutableArray array];
            CGFloat prevValue = 0, intervalVal = 0.104719755;//6.28318531
            CGFloat prevTimeValue = 0, intervalTimeVal = 0.01666666666;
            for (int i = 0; i < 60; i++) {
                [animationValues addObject:[NSNumber numberWithFloat:prevValue]];
                [animationTimes addObject:[NSNumber numberWithFloat:prevTimeValue]];
                prevValue += intervalVal;
                prevTimeValue += intervalTimeVal;
            }
            animation.values = animationValues;
            animation.keyTimes = animationTimes;
            animation.removedOnCompletion = NO;
            animation.fillMode = kCAFillModeForwards;
            [layer addAnimation:animation forKey:nil];
            animationBlock = ^void(){};
        }else if ([animVerb isEqualToString:@"replace"]){
            [_animateObject stopAnimating];
            NSString *imageName = [animParams objectAtIndex:2];
            UIImage *imageToReplace = [UIImage imageNamed:imageName];
            [_animateObject setImage:imageToReplace];
            CGRect curRect = _animateObject.frame;
            NSUInteger animCount = animParams.count;
            if (animCount > 4) {
                NSString *newXPos = [animParams objectAtIndex:3];
                if (newXPos.length) {
                    curRect.origin.x = [P2MSObjectWrapper getPosFromString:newXPos withParentView:_animateObject.superview];
                }
                if (animCount > 5) {
                    NSString *newYPos = [animParams objectAtIndex:4];
                    if (newYPos.length) {
                        curRect.origin.y = [P2MSObjectWrapper getPosFromString:newYPos withParentView:_animateObject.superview];
                    }
                    if (animCount > 6) {
                        NSString *newWidth = [animParams objectAtIndex:5];
                        if (newWidth.length) {
                            curRect.size.width = [newWidth floatValue];
                        }else
                            curRect.size.width = imageToReplace.size.width;
                        if (animCount > 7) {
                            NSString *newHeight = [animParams objectAtIndex:6];
                            if (newHeight.length) {
                                curRect.size.height = [newHeight floatValue];
                            }else
                                curRect.size.height = imageToReplace.size.height;
                        }
                    }
                }
            }
            _animateObject.frame = curRect;
            animPeriod = 0.0;
            animationBlock = ^void(){};
        }else if ([animVerb isEqualToString:@"reset_transform"]){
            if (animPeriod) {
                animationBlock = ^void(){
                    _animateObject.transform = CGAffineTransformIdentity;
                };
            }else{
                _animateObject.transform = CGAffineTransformIdentity;
                animationBlock = ^void(){};
            }
            
        }else if ([animVerb isEqualToString:@"animate"]){
            NSArray *imageNames = [[animParams objectAtIndex:2]componentsSeparatedByString:@"##"];
            CGFloat imgWidth = _animateObject.bounds.size.height, imgHeight = _animateObject.bounds.size.height;
            if (imageNames.count) {
                NSMutableArray *images = [NSMutableArray array];
                for (NSString *imageName in imageNames) {
                    [images addObject:[UIImage imageNamed:imageName]];
                }
                UIImage *lastImage = [images lastObject];
                imgWidth = lastImage.size.width;
                imgHeight = lastImage.size.height;
                _animateObject.image = [images lastObject];
                [_animateObject setAnimationImages:images];
            }
            CGRect curRect = _animateObject.frame;
            curRect.size = _animateObject.bounds.size;
            NSUInteger animCount = animParams.count;

            if (animCount >= 6) {
                NSString *newXPos = [animParams objectAtIndex:5];
                if (newXPos.length) {
                    curRect.origin.x = [P2MSObjectWrapper getPosFromString:newXPos withParentView:_animateObject.superview];
                }
                if (animCount >= 7) {
                    NSString *newYPos = [animParams objectAtIndex:6];
                    if (newYPos.length) {
                        curRect.origin.y = [P2MSObjectWrapper getPosFromString:newYPos withParentView:_animateObject.superview];
                    }
                    if (animCount >= 8) {
                        NSString *newWidth = [animParams objectAtIndex:7];
                        if (newWidth.length) {
                            curRect.size.width = [newWidth floatValue];
                        }else
                            curRect.size.width = imgWidth;
                        if (animCount >= 9) {
                            NSString *newHeight = [animParams objectAtIndex:8];
                            if (newHeight.length) {
                                curRect.size.height = [newHeight floatValue];
                            }else
                                curRect.size.height = imgHeight;
                        }
                    }
                }
            }
            _animateObject.frame = curRect;
            if (animCount > 3) {
                NSString *period = [animParams objectAtIndex:3];
                if (period.length) {
                    CGFloat animPeriod = [period floatValue];
                    _animateObject.animationDuration = animPeriod;
                }
                if (animCount > 4) {
                    NSString *count = [animParams objectAtIndex:4];
                    if (count.length) {
                        CGFloat animCount = [count floatValue];
                        _animateObject.animationRepeatCount = (animCount == 0)?CGFLOAT_MAX:animCount;
                    }
                }
            }
            [_animateObject startAnimating];
            animPeriod = 0.0;
            animationBlock = ^void(){};
        }else if ([animVerb isEqualToString:@"display_short"]){
            NSString *animImage = [animParams objectAtIndex:2];
            CGRect orignalRect = CGRectMake([[animParams objectAtIndex:4]floatValue], [[animParams objectAtIndex:5]floatValue], [[animParams objectAtIndex:6]floatValue], [[animParams objectAtIndex:7]floatValue]);
            CGRect finalRect = CGRectMake([[animParams objectAtIndex:9]floatValue], [[animParams objectAtIndex:10]floatValue], [[animParams objectAtIndex:11]floatValue], [[animParams objectAtIndex:12]floatValue]);
            UIImageView *shortImgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:animImage]];
            shortImgView.frame = orignalRect;
            CGFloat disappearDelay = [[animParams objectAtIndex:13]floatValue];
            
            [_animateObject.superview addSubview:shortImgView];
            [UIView animateWithDuration:animPeriod animations:^{
                shortImgView.frame = finalRect;
            } completion:^(BOOL finished) {
                [self performSelector:@selector(removeShortDisplay:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:shortImgView, @"image", nil] afterDelay:disappearDelay];
            }];
            animationBlock = ^void(){};
        }
        else{
            animationBlock = ^void(){};
            curAnimateCount--;
        }
        [UIView animateWithDuration:animPeriod delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            animationBlock();
        } completion:^(BOOL finished) {
            if (isMove) {
                [_animateObject stopAnimating];
            }
            if (finished) {
                [self waitForAnimationToFinish];
            }
        }];
    }
}

- (void)removeShortDisplay:(NSDictionary *)imageData{
    UIView *imageView = [imageData objectForKey:@"image"];
    [imageView removeFromSuperview];
    imageView = nil;
}

- (void)waitForAnimationToFinish{
    curAnimateCount--;
    if (hasStopAnimationResponder) {
        [_deleage stopAnimationForObject:self forAnimationIndex:curAnimationIndex];
    }
    if (curAnimateCount <= 0) {
        [self animateForIndex:curAnimationIndex+1];
    }
}

- (void)delayedAnimatoinSequence:(NSString *)animSequence{
    NSArray *animParts = [animSequence componentsSeparatedByString:@":"];
    NSArray *animParams = [[animParts objectAtIndex:1]componentsSeparatedByString:@","];
    NSString *animVerb = [animParts objectAtIndex:0];
    [self performAnimationForVerb:animVerb andAnimParams:animParams];
}



@end
