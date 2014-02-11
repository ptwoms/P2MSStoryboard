//
//  P2MSScene.m
//  P2MSStoryboard
//
//  Created by PYAE PHYO MYINT SOE on 3/2/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "P2MSScene.h"
#import "P2MSObjectWrapper.h"
#import "P2MSAnimationObject.h"
#import "P2MSTextObject.h"

@interface P2MSScene(){
}

@end

@implementation P2MSScene

+ (P2MSScene *)loadScene:(NSString *)sceneString inRect:(CGRect)boundRect withTag:(NSInteger)tag andObjectDelegate:(id<P2MSDefaultObjectDelegate>)ObjectDelegate{
    P2MSScene *drawingCanvas = [[P2MSScene alloc]initWithFrame:boundRect];
    drawingCanvas.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    drawingCanvas.tag = tag;
    
    NSArray *arr = [sceneString componentsSeparatedByString:@"\n#\n"];
    NSArray *bkGroundProperties = [[arr objectAtIndex:0]componentsSeparatedByString:@" "];
    
    NSString *fileName = [bkGroundProperties objectAtIndex:0];
    UIImage *backgroundImage = [UIImage imageNamed:fileName];
    
    UIImageView *backGroundView = [[UIImageView alloc]initWithImage:backgroundImage];
    CGFloat bkAlpha = 1.0f;
    if (bkGroundProperties.count > 2) {
        bkAlpha = [[bkGroundProperties objectAtIndex:2]floatValue];
    }
    backGroundView.frame = CGRectMake(0, 0, drawingCanvas.frame.size.width, drawingCanvas.frame.size.height);
    backGroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    backGroundView.alpha = bkAlpha;
    [drawingCanvas addSubview:backGroundView];
    
    if (arr.count > 1) {
        for (int i = 1; i < arr.count; i++) {
            [drawingCanvas loadObjectForString:[arr objectAtIndex:i] withTag:i andDelegate:ObjectDelegate];
        }
    }
    return drawingCanvas;
}

- (void)loadObjectForString:(NSString *)objString withTag:(NSInteger)tag andDelegate:(id<P2MSDefaultObjectDelegate>)objDelegate{
    if (!_objectsInScene) {
        _objectsInScene = [NSMutableArray array];
    }
    if ([objString hasPrefix:@"object"]) {
        NSArray *imgProperties = [objString componentsSeparatedByString:@" "];
        P2MSAnimationObject *myObj = [[P2MSAnimationObject alloc]init];
        P2MSAnimation *finalAnimation = nil;
        if (imgProperties.count > 4) {
            NSString *animStr = [imgProperties objectAtIndex:4];
            finalAnimation = [P2MSAnimation animationString:animStr];
        }
        [myObj loadObject:nil withAnimation:finalAnimation associatedParentView:self withTag:tag initialParams:[NSString stringWithFormat:@"%@ %@ %@", [imgProperties objectAtIndex:1], [imgProperties objectAtIndex:2], [imgProperties objectAtIndex:3]]];
        myObj.delegate = objDelegate;
        if (objString.length > 6) {
            if ([objString rangeOfString:@"tap"].length) {
                myObj.objectbehaviorType = OBJECT_BEHAVIOR_TYPE_BUTTON;
            }else if ([objString rangeOfString:@"drag"].length){
                myObj.objectbehaviorType = OBJECT_BEHAVIOR_TYPE_DRAG;
            }
        }
        [_objectsInScene addObject:myObj];
    }else if ([objString hasPrefix:@"text"]){
        NSArray *objText = [objString componentsSeparatedByString:@"\n###\n"];
        NSArray *txtProperties = [[objText objectAtIndex:0]componentsSeparatedByString:@" "];
        P2MSAnimation *finalAnimation = nil;
        if (txtProperties.count > 4) {
            NSString *animStr = [txtProperties objectAtIndex:4];
            finalAnimation = [P2MSAnimation animationString:animStr];
        }
        P2MSTextObject *textObj = [[P2MSTextObject alloc]init];
        [textObj loadObject:[objText subarrayWithRange:NSMakeRange(1, objText.count-1)] withAnimation:finalAnimation associatedParentView:self withTag:tag initialParams:[NSString stringWithFormat:@"%@ %@ %@", [txtProperties objectAtIndex:1], [txtProperties objectAtIndex:2], [txtProperties objectAtIndex:3]]];
        textObj.delegate = objDelegate;
        [_objectsInScene addObject:textObj];
    }
}

- (void)startAnimation{
    for (P2MSAnimationObject *animObject in _objectsInScene) {
        [animObject startTask];
    }
}

- (void)stopAnimation{
    for (P2MSAnimationObject *animObject in _objectsInScene) {
        [animObject removeObject:YES];
    }
    [_objectsInScene removeAllObjects];
}



@end
