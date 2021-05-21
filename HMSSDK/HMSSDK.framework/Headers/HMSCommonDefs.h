//
//  HMSCommonDefs.h
//  HMSSDK
//
//  Created by Dmitry Fedoseyev on 10.09.2020.
//  Copyright © 2020 100ms. All rights reserved.
//

#ifndef HMSCommonDefs_h
#define HMSCommonDefs_h
#import <CoreGraphics/CGGeometry.h>

@class HMSError;

typedef void (^HMSOperationStatusHandler)(BOOL isSuccess, NSError * _Nullable error);
typedef void (^HMSRequestCompletionHandler)(id _Nullable result, NSError * _Nullable error);

typedef NS_ENUM(NSUInteger, HMSVideoCodec) {
    kHMSVideoCodecH264,
    kHMSVideoCodecVP8
};

typedef NS_ENUM(NSUInteger, HMSSimulcastLayer) {
    kHMSSimulcastLayerHigh,
    kHMSSimulcastLayerMid,
    kHMSSimulcastLayerLow,
    kHMSSimulcastLayerNone
};

typedef NS_ENUM(NSUInteger, HMSTrackKind) {
    kHMSTrackKindAudio,
    kHMSTrackKindVideo
};

typedef NS_ENUM(NSUInteger, HMSTrackSource) {
    kHMSTrackSourceRegular,
    kHMSTrackSourceScreen,
    kHMSTrackSourcePlugin
};

typedef NS_ENUM(NSUInteger, HMSCameraFacing) {
    kHMSCameraFacingFront,
    kHMSCameraFacingBack
};

typedef struct CGSize HMSVideoResolution;

typedef NS_ENUM(NSUInteger, HMSLogLevel) {
    kHMSLogLevelOff = 0,
    kHMSLogLevelError = 1,
    kHMSLogLevelWarning = 2,
    kHMSLogLevelInfo = 3,
    kHMSLogLevelVerbose = 4
};

typedef NS_ENUM(NSInteger, HMSAnalyticsEventLevel) {
    kHMSAnalyticsEventLevelOff,
    kHMSAnalyticsEventLevelError,
    kHMSAnalyticsEventLevelInfo,
    kHMSAnalyticsEventLevelVerbose
};

typedef NS_ENUM(NSUInteger, HMSVideoConnectionState) {
    kHMSVideoConnectionStateReady,
    kHMSVideoConnectionStateConnecting,
    kHMSVideoConnectionStateConnected,
    kHMSVideoConnectionStateDisconnected,
    kHMSVideoConnectionStateReconnecting,
    kHMSVideoConnectionStateFailed
};

@protocol HMSLogger <NSObject>
@property (nonatomic, assign) HMSLogLevel logLevel;

- (void)logMessage:(NSString * __nonnull)message withLogLevel:(HMSLogLevel)level;
@end


#endif /* HMSCommonDefs_h */
