//
//  NSObject+P2MSPerformSelector.h
//  P2MSStoryboard
//
//  Created by PYAE PHYO MYINT SOE on 16/1/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimerSelector : NSObject

@property (nonatomic) NSInteger intervalLeft;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) SEL selector;
@property (nonatomic) id argument;
@property (nonatomic, strong) NSString *referenceID;

@end


//Proxy object for target
@interface WeakTimerTarget : NSObject

@property (nonatomic, unsafe_unretained)NSObject *targetObject;

- (id)initWithTarget:(id)target;

@end


@interface NSObject (P2MSPerformSelector)

@property(nonatomic,retain) NSMutableDictionary *selectors;

- (void)performP2MSSelector:(SEL)new_selector withObject:(id)object afterDelay:(NSTimeInterval)delayTime;
- (void)cancelSelector:(SEL)selector;
- (void)cancelAllSelectors;
- (void)pauseAllSelectors;
- (void)resumeAllSelectors;
- (IBAction)timerTip:(NSTimer *)sender;

@end
