//
//  P2MSStandarBehavior.h
//  P2MSStoryboard
//
//  Created by PYAE PHYO MYINT SOE on 16/1/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "P2MSObjectBehavior.h"

@interface P2MSStandardBehavior : NSObject<P2MSObjectBehavior>
@end

@interface P2MSMoveBehavior : P2MSStandardBehavior
@end


@interface P2MSMoveScaleBehavior : P2MSStandardBehavior
@end

@interface P2MSImageAnimationBehavior : P2MSStandardBehavior
@end

@interface P2MSRotateBehavior : P2MSStandardBehavior
@end

@interface P2MSClockRotateBehavior : P2MSStandardBehavior
@end

@interface P2MSFlipRotateBehavior : P2MSStandardBehavior
@end


@interface P2MSAlphaBehavior : P2MSStandardBehavior
@end

@interface ReplaceImage : P2MSStandardBehavior
@end

@interface ResetTransform : P2MSStandardBehavior
@end

@interface AnimationObjectDependency : P2MSStandardBehavior
@end