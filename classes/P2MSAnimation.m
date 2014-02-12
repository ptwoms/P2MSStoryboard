//
//  P2MSAnimation.m
//  P2MSStoryboard
//
//  Created by PYAE PHYO MYINT SOE on 8/2/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "P2MSAnimation.h"

//This structure is used for creating nodes by searching text between brackets []
@interface HierarchyRanking : NSObject
@property(nonatomic) NSRange range;
@property (nonatomic) NSInteger level;
@property (nonatomic, retain) NSMutableArray *childRankings;

@end

@implementation HierarchyRanking
@end

@interface P2MSAnimation()

+ (id)animationString:(NSString *)animString repeatCount:(CGFloat)repeatCount;
+ (id)animationWithChildAnimations:(NSArray *)childAnimation repeatCount:(CGFloat)repeatCount;

@end

@implementation P2MSAnimation

+ (id)animationString:(NSString *)animString repeatCount:(CGFloat)repeatCount{
    P2MSAnimation *animation = [[P2MSAnimation alloc]init];
    animation.repeatCount = (repeatCount == 0)?CGFLOAT_MAX:repeatCount;
    animation.animationString = animString;
    return animation;
}

+ (id)animationWithChildAnimations:(NSArray *)childAnimation repeatCount:(CGFloat)repeatCount{
    P2MSAnimation *animation = [[P2MSAnimation alloc]init];
    animation.repeatCount = (repeatCount == 0)?CGFLOAT_MAX:repeatCount;
    int i = 0;
    for (P2MSAnimation *anim in childAnimation) {
        anim.childIndex = i++;
        anim.parent = animation;
    }
    animation.childAnimation = childAnimation;
    return animation;
}

+ (id)animationString:(NSString *)animString repeatCount:(CGFloat)repeatCount serialIndex:(NSInteger)serialIndex{
    P2MSAnimation *animation = [[P2MSAnimation alloc]init];
    animation.repeatCount = (repeatCount == 0)?CGFLOAT_MAX:repeatCount;
    animation.animationString = animString;
    animation.serialIndex = serialIndex;
    return animation;
}

+ (id)animationWithChildAnimations:(NSArray *)childAnimation repeatCount:(CGFloat)repeatCount serialStartIndex:(NSInteger)serialStartIndex{
    P2MSAnimation *animation = [[P2MSAnimation alloc]init];
    animation.repeatCount = (repeatCount == 0)?CGFLOAT_MAX:repeatCount;
    int i = 0;
    for (P2MSAnimation *anim in childAnimation) {
        anim.childIndex = i++;
        anim.serialIndex = serialStartIndex++;
        anim.parent = animation;
    }
    animation.childAnimation = childAnimation;
    return animation;
}



+ (id)animationFromString:(NSString *)animString{
    NSString *trimmedString = [animString stringByReplacingOccurrencesOfString:@" " withString:@""];
    return [P2MSAnimation createAnimationsLinearly:trimmedString];
}

//level based indexing (O(n)) instead of searching recursively
+ (P2MSAnimation *)createAnimationsLinearly:(NSString *)subString{
    NSScanner *theScanner= [NSScanner scannerWithString:subString];
    theScanner.charactersToBeSkipped = nil;
    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"[]"];
    BOOL found = NO;
    NSString *scannedStr = nil;
    NSUInteger strLength = subString.length;
    NSMutableArray *list = [NSMutableArray array];
    
    NSMutableArray *indexes = [NSMutableArray array];
    do {
        NSUInteger curLoc =[theScanner scanLocation];
        if (curLoc < strLength) {
            unichar firstChar = [subString characterAtIndex:curLoc];
            if (firstChar == '[') {
                [indexes addObject:[NSNumber numberWithInteger:curLoc]];
                found = YES;
            }else if (firstChar == ']'){
                NSNumber *lastNumber = [indexes lastObject];
                NSInteger lastIndex = [lastNumber integerValue]+1;
                HierarchyRanking *ranking = [[HierarchyRanking alloc]init];
                ranking.level = indexes.count;
                ranking.range = NSMakeRange(lastIndex, curLoc-lastIndex);
                [list addObject:ranking];
                [indexes removeObject:lastNumber];
                found = YES;
            }else{
                scannedStr = nil;
                found = [theScanner scanUpToCharactersFromSet:charSet intoString:&scannedStr];
            }
        }else{
            found = NO;
            break;
        }
        [theScanner setScanLocation:curLoc+1];
    } while (found);
    
    int serialIndex = 1;
    NSMutableArray *finalList = [NSMutableArray array];
    for (HierarchyRanking *ranking in list) {
        HierarchyRanking *lastRanking = [finalList lastObject];
        if (lastRanking) {
            if (lastRanking.level == ranking.level || ranking.level > lastRanking.level) {
                [finalList addObject:ranking];
            }else{
                NSMutableArray *children = [NSMutableArray array];
                int lastLevel = lastRanking.level;
                while (lastRanking && lastRanking.level == lastLevel) {
                    P2MSAnimation *anim = [self getAnimationFromRanking:lastRanking forString:subString withSerialIndex:&serialIndex];
                    [children insertObject:anim atIndex:0];
                    [finalList removeObject:lastRanking];
                    lastRanking = [finalList lastObject];
                }
                ranking.childRankings = children;
                [finalList addObject:ranking];
            }
        }else{
            [finalList addObject:ranking];
        }
    }
    P2MSAnimation *rootAnimation = nil;
    if (finalList.count == 1) {
        HierarchyRanking *ranking = [finalList lastObject];
        rootAnimation = [self getAnimationFromRanking:ranking forString:subString withSerialIndex:&serialIndex];
    }else if(finalList.count > 1){
        NSMutableArray *childAnims = [NSMutableArray array];
        for (HierarchyRanking *ranking in finalList) {
            [childAnims addObject:[self getAnimationFromRanking:ranking forString:subString withSerialIndex:&serialIndex]];
        }
        rootAnimation = [P2MSAnimation animationWithChildAnimations:childAnims repeatCount:1];
    }else if (finalList.count == 0 && subString.length){
        return [P2MSAnimation animationString:subString repeatCount:1 serialIndex:serialIndex];
    }
    [self correctSerialIndex:rootAnimation totalLeaves:serialIndex];
    return rootAnimation;
}

+ (void)correctSerialIndex:(P2MSAnimation *)animation totalLeaves:(NSInteger)leavesCount{
    if (animation.childAnimation.count) {
        for (P2MSAnimation *anim in animation.childAnimation) {
            [self correctSerialIndex:anim totalLeaves:leavesCount];
        }
    }else{
        animation.serialIndex = leavesCount - animation.serialIndex;
    }
}

+ (CGFloat)getRepeatCountFrom:(NSString *)strFromRange withRange:(NSRange)range{
    CGFloat repeatCount = 1;
    if (range.length > 0) {
        int intLoc = range.location+1;
        int strLength = strFromRange.length;
        if (intLoc < strLength) {
            NSString *intString = [strFromRange substringWithRange:NSMakeRange(intLoc, strLength-intLoc)];
            NSScanner *intScanner = [NSScanner scannerWithString:intString];
            CGFloat val;
            if ([intScanner scanFloat:&val]) {
                repeatCount = val;
            }
        }
    }
    if (!repeatCount) {
        repeatCount = CGFLOAT_MAX;
    };
    return repeatCount;
}

+ (P2MSAnimation *)getAnimationFromRanking:(HierarchyRanking *)ranking forString:(NSString *)subString withSerialIndex:(NSInteger *)serialIndex{
    NSString *strFromRange = [subString substringWithRange:ranking.range];
    NSRange range = [strFromRange rangeOfString:@";" options:NSBackwardsSearch];
    CGFloat repeatCount = [self getRepeatCountFrom:strFromRange withRange:range];
    if (ranking.childRankings.count > 0) {
        return [P2MSAnimation animationWithChildAnimations:ranking.childRankings repeatCount:repeatCount];
    }else{
        if (range.length) {
            strFromRange = [strFromRange substringToIndex:range.location];
        }
        P2MSAnimation *leafNode = [P2MSAnimation animationString:strFromRange repeatCount:repeatCount];
        leafNode.serialIndex = (*serialIndex);
        *serialIndex = (*serialIndex)+1;
        return leafNode;
    }
}

@end
