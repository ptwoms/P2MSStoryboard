//
//  NSObject+P2MSPerformSelector.m
//  P2MSStoryboard
//
//  Created by PYAE PHYO MYINT SOE on 16/1/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "NSObject+P2MSPerformSelector.h"

#import <objc/runtime.h>

@implementation TimerSelector

@end

@implementation WeakTimerTarget

- (id)initWithTarget:(id)target{
    if (self = [super init]) {
        self.targetObject = target;
    }
    return self;
}

- (void)timerFired:(NSTimer *)timer{
    if (_targetObject) {
        [_targetObject performSelector:@selector(timerTip:) withObject:timer];
    }else{
        [timer invalidate];
    }
}

@end

static char const * const selectorKey = "selKeyTag";


@implementation NSObject (P2MSPerformSelector)

@dynamic selectors;

- (NSMutableDictionary *)selectors{
    return objc_getAssociatedObject(self, selectorKey);
}

- (void)setSelectors:(NSMutableDictionary *)selectors{
    objc_setAssociatedObject(self, selectorKey, selectors, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (void)invokeMethod:(SEL) selector withArguments:(id) argument{
    NSMethodSignature *ms = nil;
    if (![self respondsToSelector:selector] || !(ms =[self methodSignatureForSelector:selector])) {
        return;
    }
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:ms];
    [inv setTarget:self];
    [inv setSelector:selector];
    if (argument) {
        [inv setArgument:&argument atIndex:2];
    }
    [inv invoke];
}


- (void)cancelAllSelectors{
    NSMutableDictionary *allSelectors = self.selectors;
    for (NSString *curKey in allSelectors) {
        TimerSelector *curSelector = [allSelectors objectForKey:curKey];
        if (curSelector.timer && [curSelector.timer isValid]) {
            [curSelector.timer invalidate];
        }
        curSelector.timer = nil;
    }
    [allSelectors removeAllObjects];
}


- (void)pauseAllSelectors{
    NSMutableDictionary *allSelectors = self.selectors;
    NSMutableArray *timersToDel = [NSMutableArray array];
    
    for (NSString *curKey in allSelectors) {
        TimerSelector *curSelector = [allSelectors objectForKey:curKey];
        if (!curSelector.timer) {
            continue;
        }
        NSTimeInterval interval = [curSelector.timer.fireDate timeIntervalSinceNow];
        if (interval > 0) {
            [curSelector.timer invalidate];
            curSelector.intervalLeft = interval;
            curSelector.timer = nil;
        }else{
            [timersToDel addObject:curKey];
        }
    }
    [allSelectors removeObjectsForKeys:timersToDel];
}

- (void)resumeAllSelectors{
    NSMutableDictionary *allSelectors = self.selectors;
    for (NSString *curKey in allSelectors) {
        TimerSelector *curSelector = [allSelectors objectForKey:curKey];
        if (curSelector.timer) {
            continue;
        }
        curSelector.timer = [NSTimer scheduledTimerWithTimeInterval:curSelector.intervalLeft target:self selector:@selector(timerTip:) userInfo:curSelector.referenceID repeats:NO];
        curSelector.intervalLeft = 0;
    }
}

- (void)performP2MSSelector:(SEL)new_selector withObject:(id)object afterDelay:(NSTimeInterval)delayTime{
    if (delayTime <= 0) {
        [self invokeMethod:new_selector withArguments:object];
    }else{
        TimerSelector *newTimerSelector = [[TimerSelector alloc]init];
        CFUUIDRef theUUID = CFUUIDCreate(NULL);
        CFStringRef string = CFUUIDCreateString(NULL, theUUID);
        CFRelease(theUUID);
        NSString *guidString = (__bridge NSString *)string;
        newTimerSelector.selector = new_selector;
        newTimerSelector.argument = object;
        newTimerSelector.referenceID = guidString;
        if (!self.selectors) {
            self.selectors = [NSMutableDictionary dictionary];
        }
        WeakTimerTarget *weakTarget = [[WeakTimerTarget alloc]initWithTarget:self];
        newTimerSelector.timer = [NSTimer scheduledTimerWithTimeInterval:delayTime target:weakTarget selector:@selector(timerFired:) userInfo:guidString repeats:NO];
        [self.selectors setObject:newTimerSelector forKey:guidString];
    }
}

- (void)cancelSelector:(SEL)selector{
    NSMutableArray *timerToDel = [NSMutableArray array];
    for (NSString *guidString in self.selectors) {
        TimerSelector *timer = [self.selectors objectForKey:guidString];
        if (timer.selector == selector) {
            [timer.timer invalidate];
            [timerToDel addObject:timer.referenceID];
        }
    }
    for (NSString *timerSel in timerToDel) {
        [self.selectors removeObjectForKey:timerSel];
    }
}

- (IBAction)timerTip:(NSTimer *)sender{
    TimerSelector *timerSelToInvoke = [self.selectors objectForKey:sender.userInfo];
    if (timerSelToInvoke) {
        NSString *userInfo = sender.userInfo;
        id argument = [timerSelToInvoke.argument copy];
        [self invokeMethod:timerSelToInvoke.selector withArguments:argument];
        [self.selectors removeObjectForKey:userInfo];
    }
    [sender invalidate];
}

@end
