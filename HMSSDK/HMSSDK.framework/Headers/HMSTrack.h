//
//  HMSTrack.h
//  HMSSDK
//
//  Created by Dmitry Fedoseyev on 23.03.2021.
//  Copyright © 2021 100ms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMSCommonDefs.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kHMSTrackStateDidChangeNotification;

/// A track represents either the audio or video that makes up a stream
@interface HMSTrack : NSObject
@property (nonatomic, readonly) NSString *trackId;
@property (nonatomic, readonly) HMSTrackKind kind;
@property (nonatomic, assign, readonly) HMSTrackSource source;
@property (nonatomic, copy, readonly) NSString *trackDescription;

- (BOOL)isMute;

@end

NS_ASSUME_NONNULL_END
