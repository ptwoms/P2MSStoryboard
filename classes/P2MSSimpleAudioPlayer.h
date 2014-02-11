//
//  P2MSSimpleAudioPlayer.h
//  P2MSStoryboard
//
//  Created by PYAE PHYO MYINT SOE on 3/2/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface P2MSSimpleAudioPlayer : NSObject<AVAudioPlayerDelegate>

@property (nonatomic, retain) NSString *playerFilePath;
@property (nonatomic, retain) NSData *audioData;

@property (nonatomic) BOOL isPlayStarted;
//@property (nonatomic, unsafe_unretained) id<P2MSSimpleAudioPlayerDelegate> delegate;

- (void)playAudioWithData:(NSData *)data;
- (void)pauseAudio;
- (void)resumeAudio;
- (void)stopAudio;
- (BOOL)isAudioPlaying;
- (void)speakerMuted:(BOOL)muted;
- (void)playAudioForPath:(NSString *)audioFilePath withVolume:(CGFloat)volume repeat:(NSInteger)repeatCount;

@end
