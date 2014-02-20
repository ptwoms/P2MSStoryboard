//
//  P2MSStoryboard.m
//  P2MSStoryboard
//
//  Created by PYAE PHYO MYINT SOE on 3/2/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "P2MSStoryboard.h"
#import "P2MSScene.h"
#import "NSString+MD5.h"

@interface P2MSStoryboard(){
    NSArray *scenes;//array of scene string
    P2MSScene *tempScene;
    NSMutableDictionary *fileDownloadProgress;
}
@property (nonatomic, retain) P2MSScene *curScene;

@end

@implementation P2MSStoryboard

- (id)init{
    self = [super init];
    if (self) {
//        _cacheFilesBasePath = @"Library/Caches/Pictures";
    }
    return self;
}

///////////////////////////////////////////////////////////
//    Load all the scenes for the storyboard from the file
///////////////////////////////////////////////////////////
/*
    It is required to add the text lines in the scene string and the scenes are separated by \n##\n.
    the objects in the scene are divided by \n#\n
 
    text strings in the text object are spearated by \n###\n
 */
- (void)loadScenesFromFilePath:(NSString *)filePath{
    NSError *error;
    NSString *animRawString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
//    NSString *animString =  [animRawString stringByReplacingOccurrencesOfString:@"//.*\n" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, animRawString.length)];
//    scenes = [animString componentsSeparatedByString:@"\n##\n"];
    scenes = [animRawString componentsSeparatedByString:@"\n##\n"];
    _totalScenes = scenes.count;
}

- (void) downloadImage:(NSURL *)url withCacheImageName:(NSString *)cacheImageName{
    NSString *key = [url absoluteString];
    LazyImageDownloader *imgDownloader = [fileDownloadProgress objectForKey:key];
    if(imgDownloader == nil){
        imgDownloader = [[LazyImageDownloader alloc]init];
        imgDownloader.returnPath = key;
        imgDownloader.cacheName = cacheImageName;
        imgDownloader.retryCount = 1;//retry one time if image load failed
        imgDownloader.delegate = self;
        if (!fileDownloadProgress) {
            fileDownloadProgress = [NSMutableDictionary dictionary];
        }
        [fileDownloadProgress setObject:imgDownloader forKey:key];
        [imgDownloader startURLDownload:url];
    }
}

- (void)preloadRemoteImagesForScenes{
    NSString *animRawString = [scenes componentsJoinedByString:@"\n"];
    animRawString = [animRawString stringByReplacingOccurrencesOfString:@"#|,|\\|" withString:@" " options:NSRegularExpressionSearch range:NSMakeRange(0, animRawString.length)];
    NSError *error;
    NSDataDetector* detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray* matches = [detector matchesInString:animRawString options:0 range:NSMakeRange(0, [animRawString length])];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *picCacheDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/Pictures"];
    if (![fileManager contentsOfDirectoryAtPath:picCacheDirectory error:&error]) {
        NSArray *dirPaths;
        NSString *newDir;
        dirPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        newDir = [[dirPaths objectAtIndex:0] stringByAppendingPathComponent:@"Pictures"];
        if ([fileManager createDirectoryAtPath:newDir withIntermediateDirectories:YES attributes:nil error: NULL] == YES)
        {
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Create Folder" message:[error description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
    for (NSTextCheckingResult *txtResult in matches) {
        if (txtResult.resultType == NSTextCheckingTypeLink) {
            NSURL *txtLink = [txtResult URL];
            NSString *absLink = [txtLink absoluteString];
            NSString *imageName = [absLink lastPathComponent];
            NSString *cacheImageName = [NSString stringWithFormat:@"img_%@_%@", [absLink MD5String], imageName];
            if (![fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", picCacheDirectory, cacheImageName]]) {
                [self downloadImage:txtLink withCacheImageName:cacheImageName];
            }
        }
    }
    if (!fileDownloadProgress.count && [_delegate respondsToSelector:@selector(allRemoteImageLoaded:)]) {
        [_delegate allRemoteImageLoaded:self];
    }
}

- (void)startReading{
    if (self.superview) {
        _curSceneIndex = 0;
        [self displaySceneForIndex:_curSceneIndex];
    }
}

- (void)previousScene{
    if (_curSceneIndex > 0) {
        [self displaySceneForIndex:_curSceneIndex-1];
    }
}

- (void)nextScene{
    if (_curSceneIndex < _totalScenes-1) {
        [self displaySceneForIndex:_curSceneIndex+1];
    }
}

- (void)displaySceneForIndex:(NSInteger)index{
    if (index < scenes.count) {
        _curSceneIndex = index;
        if (tempScene) {
            [tempScene stopAnimation];
            tempScene = nil;
        }
        tempScene = [P2MSScene loadScene:[scenes objectAtIndex:index] inRect:self.bounds withTag:index andObjectDelegate:self];
        [self addSubview:tempScene];
        if (_curScene) {
            [_curScene stopAnimation];
            [self performTransitionOnView:tempScene andNextView:_curScene animType:kCATransitionFade subType:kCATransitionFade];
            if ([_delegate respondsToSelector:@selector(changedToScene:)]) {
                [_delegate changedToScene:_curSceneIndex+1];
            }
        }else{
            _curScene = tempScene;
            [tempScene startAnimation];
        }
    }
}

- (void)performTransitionOnView:(UIView *)viewOne andNextView:(UIView *)viewTwo animType:(NSString *)animType subType:(NSString *)animSubType{
    if ([animType isEqualToString:kCATransitionFade]) {
        tempScene.hidden = YES;
        CATransition* transition = [CATransition animation];
        transition.delegate = self;
        transition.type = animType;
        transition.duration = 1.25;
        [self.layer addAnimation:transition forKey:@"transition"];
        viewTwo.hidden = YES;
        viewOne.hidden = NO;
    }else{
        CATransition* transition = [CATransition animation];
        transition.startProgress = 1.0;
        transition.delegate = self;
        transition.endProgress = 0.0;
        transition.type = animType;
        transition.subtype = animSubType;
        transition.duration = 1.25;
        [viewOne.layer addAnimation:transition forKey:@"transition"];
        [viewTwo.layer addAnimation:transition forKey:@"transition"];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (tempScene) {
        _curScene = tempScene;
        tempScene = nil;
        [_curScene startAnimation];
    }
}

- (void)animationDone:(P2MSAnimationObject *)animatedObject{
    //remove the inactive animation object from the memory
    if (animatedObject.objectbehaviorType == OBJECT_BEHAVIOR_TYPE_DISABLED || animatedObject.objectbehaviorType == OBJECT_BEHAVIOR_TYPE_DEFAULT ) {
        [_curScene.objectsInScene removeObject:animatedObject];
    }
}

- (void)objectClicked:(P2MSAnimationObject *)animatedObject{
    if ([_delegate respondsToSelector:@selector(clickedObject:forSceneIndex:)]) {
        [_delegate clickedObject:animatedObject forSceneIndex:_curSceneIndex+1];
    }
}

- (void)objectDragged:(P2MSAnimationObject *)animatedObject at:(CGPoint)curPos withGestureRecognizer:(UIPanGestureRecognizer *)gesture{
    if ([_delegate respondsToSelector:@selector(draggedObject:at:withGestureRecognizer:forSceneIndex:)]) {
        [_delegate draggedObject:animatedObject at:curPos withGestureRecognizer:gesture forSceneIndex:_curSceneIndex+1];
    }
}

- (void)imageDidFail:(LazyImageDownloader *)imageDownloader forURLString:(NSString *)url{
    NSLog(@"Image load failed %@", url);
    //do something here
    if ([_delegate respondsToSelector:@selector(remoteImageLoadFailed:)]) {
        [_delegate remoteImageLoadFailed:url];
    }
}

- (void)imageDidLoad:(id)returnPath withImage:(UIImage *)image{
    NSLog(@"Image loaded %@", returnPath);
    LazyImageDownloader *iconDownloader = [fileDownloadProgress objectForKey:returnPath];
    if (iconDownloader) {
        [fileDownloadProgress removeObjectForKey:returnPath];
    }
    if (!fileDownloadProgress.count && [_delegate respondsToSelector:@selector(allRemoteImageLoaded:)]) {
        [_delegate allRemoteImageLoaded:self];
    }
}



@end
