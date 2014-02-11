//
//  P2MSStoryboard.h
//  P2MSStoryboard
//
//  Created by PYAE PHYO MYINT SOE on 3/2/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "P2MSAnimationObject.h"

@protocol P2MSStoryboardDelegate <NSObject>

- (void)clickedObject:(id<P2MSAbstractObject>)object forSceneIndex:(NSInteger)sceneIndex;
- (void)draggedObject:(id<P2MSAbstractObject>)object at:(CGPoint)curPosition withGestureRecognizer:(UIGestureRecognizer *)gesture forSceneIndex:(NSInteger)sceneIndex;
- (void)changedToScene:(NSInteger)sceneIndex;

@end


@interface P2MSStoryboard : UIView<P2MSDefaultObjectDelegate>

@property (nonatomic, readonly) NSInteger curSceneIndex;
@property (nonatomic, unsafe_unretained) id<P2MSStoryboardDelegate> delegate;
@property (nonatomic, readonly) NSUInteger totalScenes;

- (void)loadScenesFromFilePath:(NSString *)filePath;
- (void)startReading;
- (void)nextScene;
- (void)previousScene;

@end
