//
//  UIView+P2MSUIViewAnimation.h
//  P2MSStoryboard
//
//  Created by PYAE PHYO MYINT SOE on 16/1/14.
//

#import <UIKit/UIKit.h>

@interface UIView (P2MSUIViewAnimation)

- (void) pauseAnimation;
- (BOOL) isAnimationPaused;
- (void) resumeAnimation;
- (void) cancelAnimation:(BOOL)keepLatest;

@end
