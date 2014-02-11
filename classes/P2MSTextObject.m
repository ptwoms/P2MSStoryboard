//
//  P2MSTextObject.m
//  P2MSStoryboard
//
//  Created by PYAE PHYO MYINT SOE on 8/2/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "P2MSTextObject.h"
#import "P2MSObjectWrapper.h"

@interface P2MSTextObject(){
    CGRect _initialRect;
    NSArray *_textArray;
}

@end
@implementation P2MSTextObject

//format: text text_index alpha,font_name,font_size,color_r,color_g,color_b,color_alpha
//followed by text array separated by \n###\n ( text array is indexed by text_index )
//
//text_index: #1,#2,#3,...#n
//eg, see - ExampleStory.txt
- (void)loadObject:(id)objectParams withAnimation:(id)animationParams associatedParentView:(UIView *)parentView withTag:(NSInteger)tagNumber initialParams:(NSString *)initParams{
    [super loadObject:objectParams withAnimation:animationParams associatedParentView:parentView withTag:tagNumber initialParams:initParams];
    _textArray = objectParams;
    NSArray *arr = [initParams componentsSeparatedByString:@" "];
    _initialRect = [P2MSObjectWrapper getRectFromString:[arr objectAtIndex:1] withParentView:parentView];
    if (self.view) {
        [self.view removeFromSuperview];
        self.view = nil;
    }
    UILabel *label = [[UILabel alloc]initWithFrame:_initialRect];
    if (_textArray.count > 0) {
        label.text = [self getStringForPosition:[arr objectAtIndex:0]];
    }
    label.backgroundColor = [UIColor clearColor];
    NSArray *alphaColor = nil;
    if (arr.count>2) {
        alphaColor = [[arr objectAtIndex:2]componentsSeparatedByString:@","];
        label.alpha = [[alphaColor objectAtIndex:0]floatValue];
        if (alphaColor.count>2) {
            label.font = [UIFont fontWithName:[alphaColor objectAtIndex:1] size:[[alphaColor objectAtIndex:2]floatValue]];
            if (alphaColor.count>6) {
                label.textColor = [UIColor colorWithRed:[[alphaColor objectAtIndex:3]floatValue] green:[[alphaColor objectAtIndex:4]floatValue] blue:[[alphaColor objectAtIndex:5]floatValue] alpha:[[alphaColor objectAtIndex:6]floatValue]];
            }
        }
    }
    label.tag = tagNumber;
    self.view = label;
    [parentView addSubview:self.view];
    [self setupObjectType];
}

- (void)setTextArray:(NSArray *)textArray{
    _textArray = textArray;
}

- (void)setupObjectType{
    [super setupObjectType];
    //
}


- (NSString *)getStringForPosition:(NSString *)posIndicator{
    if (posIndicator.length > 1) {
        NSString *str = [posIndicator substringFromIndex:1];
        NSInteger posIndex = [str integerValue];
        if (posIndex > 0 && posIndex <= _textArray.count) {
            return [_textArray objectAtIndex:posIndex-1];
        }
    }
    return nil;
}


@end
