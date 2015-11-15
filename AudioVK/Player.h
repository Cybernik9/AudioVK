//
//  Player.h
//  AudioVK
//
//  Created by Yurii Huber on 15.11.15.
//  Copyright © 2015 Yurii Huber. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreMedia;

@interface Player : NSObject

@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, assign) float duration;


+ (instancetype) sharedPlayer;

- (void) playWithStringPath:(NSString *)url;
- (BOOL) playerCreated;
- (float) rate;
- (void) pause;
- (void) stop;
- (void) playCurrentAudioTrack;
- (float) currentTime;
- (void) seekToTime:(CMTime)sliderValueTime;

@end