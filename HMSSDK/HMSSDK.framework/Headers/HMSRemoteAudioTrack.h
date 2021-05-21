//
//  HMSRemoteAudioTrack.h
//  HMSSDK
//
//  Created by Dmitry Fedoseyev on 23.03.2021.
//  Copyright © 2021 100ms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMSAudioTrack.h"

NS_ASSUME_NONNULL_BEGIN

@interface HMSRemoteAudioTrack : HMSAudioTrack
- (BOOL)isPlaybackAllowed;
- (void)setPlaybackAllowed:(BOOL)playbackAllowed;
@end

NS_ASSUME_NONNULL_END
