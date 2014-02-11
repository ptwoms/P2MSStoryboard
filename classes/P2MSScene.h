//
//  P2MSScene.h
//  P2MSStoryboard
//
//  Created by PYAE PHYO MYINT SOE on 3/2/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "P2MSAnimationObject.h"

@interface P2MSScene : UIView

@property (nonatomic, retain) NSMutableArray *objectsInScene;

+ (P2MSScene *)loadScene:(NSString *)sceneString inRect:(CGRect)boundRect withTag:(NSInteger)tag andObjectDelegate:(id<P2MSDefaultObjectDelegate>)ObjectDelegate;
- (void)startAnimation;
- (void)stopAnimation;
@end
