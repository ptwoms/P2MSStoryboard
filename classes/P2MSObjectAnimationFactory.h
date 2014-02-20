//
//  P2MSObjectAnimationFactory.h
//  P2MSStoryboard
//
//  Created by PYAE PHYO MYINT SOE on 16/1/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "P2MSObjectBehavior.h"

@interface P2MSObjectAnimationFactory : NSObject

+ (id<P2MSObjectBehavior>)getBehaviorFromVerb:(NSString *)animVerb andParams:(NSArray *)params forObjectType:(OBJECT_TYPE)objectType;


@end
