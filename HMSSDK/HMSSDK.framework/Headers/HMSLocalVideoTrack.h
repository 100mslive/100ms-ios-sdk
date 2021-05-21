//
//  HMSLocalVideoTrack.h
//  HMSSDK
//
//  Created by Dmitry Fedoseyev on 23.03.2021.
//  Copyright © 2021 100ms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMSVideoTrack.h"

@class HMSVideoTrackSettings;

NS_ASSUME_NONNULL_BEGIN

@interface HMSLocalVideoTrack : HMSVideoTrack
@property (nonatomic, copy) HMSVideoTrackSettings *settings;


- (void)setMute:(BOOL)mute;

- (void)startCapturing;
- (void)stopCapturing;
- (void)switchCamera;

@end

NS_ASSUME_NONNULL_END
