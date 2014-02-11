//
//  P2MSSimpleAudioPlayer.m
//  P2MSStoryboard
//
//  Created by PYAE PHYO MYINT SOE on 3/2/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "P2MSSimpleAudioPlayer.h"

@interface P2MSSimpleAudioPlayer(){
    AVAudioPlayer *aduioPlayer;
}
@end


@implementation P2MSSimpleAudioPlayer

- (void)playAudioWithData:(NSData *)data{
    [[AVAudioSession sharedInstance] setDelegate: self];
    NSError *activationError = nil;
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &error];
    if (error)
        NSLog(@"Error in setting category! %@", error);
    
    [[AVAudioSession sharedInstance] setActive: YES error: &activationError];
    if (aduioPlayer) {
        if ([aduioPlayer isPlaying]) {
            [aduioPlayer stop];
        }
        aduioPlayer = nil;
    }
    _isPlayStarted = YES;
    aduioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
    [aduioPlayer prepareToPlay];
    [aduioPlayer setVolume: 1.0];
    [aduioPlayer setDelegate: self];
    [aduioPlayer play];
}

- (void)playAudioForPath:(NSString *)audioFilePath withVolume:(CGFloat)volume repeat:(NSInteger)repeatCount{
    [[AVAudioSession sharedInstance] setDelegate: self];
    NSError *activationError = nil;
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &error];
    if (error)
        NSLog(@"Error in setting category! %@", error);
    
    [[AVAudioSession sharedInstance] setActive:YES error: &activationError];
    if (aduioPlayer) {
        if ([aduioPlayer isPlaying]) {
            [aduioPlayer stop];
        }
        aduioPlayer = nil;
    }
    _isPlayStarted = YES;
    aduioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audioFilePath] error:&error];
    [aduioPlayer stop];
    [aduioPlayer setCurrentTime:0];
    [aduioPlayer setVolume: volume];
    [aduioPlayer setDelegate: self];
    [aduioPlayer setNumberOfLoops:repeatCount];
    [aduioPlayer prepareToPlay];
    [aduioPlayer play];
}

- (void)speakerMuted:(BOOL)muted
{
    if (aduioPlayer) {
        [aduioPlayer setVolume:!muted];
    }
}

- (BOOL)isAudioPlaying{
    return (aduioPlayer && [aduioPlayer isPlaying]);
}

- (void)pauseAudio{
    if (aduioPlayer && [aduioPlayer isPlaying]) {
        [aduioPlayer pause];
    }
}

- (void)resumeAudio{
    if (aduioPlayer && ![aduioPlayer isPlaying]) {
        [aduioPlayer play];
    }
}

- (void)stopAudio{
    if (aduioPlayer && [aduioPlayer isPlaying]) {
        [aduioPlayer stop];
    }
    aduioPlayer = nil;
}


@end
