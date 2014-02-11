//
//  P2MSObject.h
//  P2MSStoryboard
//
//  Created by PYAE PHYO MYINT SOE on 21/12/13.
//  Copyright (c) 2013 PYAE PHYO MYINT SOE. All rights reserved.
//

#import <Foundation/Foundation.h>

@class P2MSObject;

@protocol P2MSObjectDelegate <NSObject>
@optional
- (void)stopAnimationForObject:(P2MSObject *)animatedObject forAnimationIndex:(NSInteger)index;
- (void)objectClicked:(P2MSObject *)animatedObject;
- (void)objectDragged:(P2MSObject *)animatedObject withGestureRecognizer:(UIPanGestureRecognizer *)gesture;
@end

@interface P2MSObject : NSObject

@property (nonatomic, retain) NSString *objectID;
@property (nonatomic, retain) NSString *animationString;
@property (nonatomic, retain) UIImageView *animateObject;

@property (nonatomic, unsafe_unretained) id deleage;

- (void)loadObject:(NSString *)objectString inView:(UIView *)parentView withTag:(NSInteger)tagNumber;
- (void)removeObject;

@end
