//
//  UIView+P2MSUIViewAnimation.m
//  P2MSStoryboard
//
//  Created by PYAE PHYO MYINT SOE on 16/1/14.
//

#import "UIView+P2MSUIViewAnimation.h"

@implementation UIView (P2MSUIViewAnimation)

//https://developer.apple.com/library/ios/qa/qa1673/_index.html
//http://alldunne.org/2011/09/how-to-pause-or-end-a-uiview-animation-via-the-calayer/
//http://www.apeth.com/iOSBook/ch17.html

-(void)pauseAnimation
{
    CALayer *layer = self.layer;
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

- (BOOL)isAnimationPaused{
    return (self.layer.speed != 0);
}

-(void)resumeAnimation
{
    CALayer *layer = self.layer;
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0f;
    layer.timeOffset = 0.0f;
    layer.beginTime = 0.0f;
    CFTimeInterval time_since_pause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = time_since_pause;
}

- (void)cancelAnimation:(BOOL)keepLatest{
    if (keepLatest)
        self.layer.transform = ((CALayer *)self.layer.presentationLayer).transform;
    [self.layer removeAllAnimations];
}

@end
