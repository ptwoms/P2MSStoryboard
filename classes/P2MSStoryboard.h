//
//  P2MSStoryboard.h
//  P2MSStoryboard
//
//  Created by PYAE PHYO MYINT SOE on 3/2/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "P2MSAnimationObject.h"
#import "LazyImageDownloader.h"

@class P2MSStoryboard;

@protocol P2MSStoryboardDelegate <NSObject>

- (void)clickedObject:(id<P2MSAbstractObject>)object forSceneIndex:(NSInteger)sceneIndex;
- (void)draggedObject:(id<P2MSAbstractObject>)object at:(CGPoint)curPosition withGestureRecognizer:(UIGestureRecognizer *)gesture forSceneIndex:(NSInteger)sceneIndex;
- (void)changedToScene:(NSInteger)sceneIndex;

@optional
- (void)allRemoteImageLoaded:(P2MSStoryboard *)storyboard;
- (void)remoteImageLoadFailed:(NSString *)imageURL;

@end


@interface P2MSStoryboard : UIView<P2MSDefaultObjectDelegate, LazyImageDownloaderDelegate>

@property (nonatomic, readonly) NSInteger curSceneIndex;
@property (nonatomic, unsafe_unretained) id<P2MSStoryboardDelegate> delegate;
@property (nonatomic, readonly) NSUInteger totalScenes;
//@property (nonatomic, retain) NSString *cacheFilesBasePath;

- (void)loadScenesFromFilePath:(NSString *)filePath;
- (void)preloadRemoteImagesForScenes;

- (void)startReading;
- (void)nextScene;
- (void)previousScene;
- (void)displaySceneForIndex:(NSInteger)index;

@end
