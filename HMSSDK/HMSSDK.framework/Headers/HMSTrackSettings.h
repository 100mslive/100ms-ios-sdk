//
//  HMSTrackSettings.h
//  HMSSDK
//
//  Created by Dmitry Fedoseyev on 30.03.2021.
//  Copyright © 2021 100ms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMSCommonDefs.h"
NS_ASSUME_NONNULL_BEGIN

@interface HMSSimulcastLayerSettings : NSObject <NSCopying>
@property (nonatomic, assign, readonly) NSInteger maxBitrate;
@property (nonatomic, assign, readonly) NSInteger maxFrameRate;
@property (nonatomic, assign, readonly) double scaleResolutionDownBy;
@property (nonatomic, copy, readonly) NSString *rid;

- (instancetype)initWitRID:(NSString *)rid maxBitrate:(NSInteger)maxBitrate maxFrameRate:(NSInteger)maxFrameRate scaleResolutionDownBy:(double)scaleResolutionDownBy;
@end

@interface HMSVideoTrackSettings : NSObject <NSCopying>
@property (nonatomic, assign, readonly) HMSCodec codec;
@property (nonatomic, assign, readonly) HMSVideoResolution resolution;
@property (nonatomic, assign, readonly) NSInteger maxBitrate;
@property (nonatomic, assign, readonly) NSInteger maxFrameRate;
@property (nonatomic, assign, readonly) HMSCameraFacing cameraFacing;
@property (nonatomic, copy, readonly, nullable) NSString *trackDescription;
@property (nonatomic, copy, readonly, nullable) NSArray<HMSSimulcastLayerSettings *> *simulcastSettings;

- (instancetype)initWithCodec:(HMSCodec)codec resolution:(HMSVideoResolution)resolution maxBitrate:(NSInteger)maxBitrate maxFrameRate:(NSInteger)maxFrameRate cameraFacing:(HMSCameraFacing)cameraFacing trackDescription:(NSString *__nullable)trackDescription;

- (instancetype)initWithCodec:(HMSCodec)codec resolution:(HMSVideoResolution)resolution maxBitrate:(NSInteger)maxBitrate maxFrameRate:(NSInteger)maxFrameRate cameraFacing:(HMSCameraFacing)cameraFacing simulcastSettings:(NSArray<HMSSimulcastLayerSettings *> *__nullable)simulcastSettings trackDescription:(NSString *__nullable)trackDescription;
- (instancetype)init;

@end

@interface HMSAudioTrackSettings : NSObject <NSCopying>
@property (nonatomic, assign, readonly) NSInteger maxBitrate;
@property (nonatomic, copy, readonly, nullable) NSString *trackDescription;


- (instancetype)initWithMaxBitrate:(NSInteger)maxBitrate trackDescription:(NSString *__nullable)trackDescription;
- (instancetype)init;

@end

@interface HMSTrackSettings : NSObject <NSCopying>
@property (nonatomic, strong, readonly, nullable) HMSVideoTrackSettings *video;
@property (nonatomic, strong, readonly, nullable) HMSAudioTrackSettings *audio;

- (instancetype)initWithVideoSettings:(HMSVideoTrackSettings *_Nullable)videoSettings audioSettings:(HMSAudioTrackSettings *_Nullable)audioSettings;
- (instancetype)init;


@end

NS_ASSUME_NONNULL_END
