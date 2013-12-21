//
//  P2MSObjectWrapper.h
//  P2MSStoryboard
//
//  Created by PYAE PHYO MYINT SOE on 21/12/13.
//  Copyright (c) 2013 PYAE PHYO MYINT SOE. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef DEGREES_TO_RADIANS
#define DEGREES_TO_RADIANS(x) (M_PI * x / 180.0)
#endif

@interface P2MSObjectWrapper : NSObject

+ (NSArray *)getNormalImages:(NSString *)imgString;
+ (NSArray *)getDraggableImages:(NSString *)imgString;

+ (NSString *)generateUniqueID;

+ (CGRect)getRectFromPoint:(NSString *)pointStr andSize:(NSString *)sizeStr withParentView:(UIView *)parentView;
+ (CGFloat)getPosFromString:(NSString *)posStr withParentView:(UIView *)parentView;
+ (CGPoint)getPointFromString:(NSString *)pointStr withParentView:(UIView *)parentView;

@end
