//
//  HMSRemoteVideoTrack.h
//  HMSSDK
//
//  Created by Dmitry Fedoseyev on 23.03.2021.
//  Copyright © 2021 100ms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMSVideoTrack.h"
#import "HMSCommonDefs.h"

NS_ASSUME_NONNULL_BEGIN

@interface HMSSimulcastLayerDefinition: NSObject
@property (nonatomic) HMSSimulcastLayer layer;
@property (nonatomic) CGSize resolution;

- (instancetype)initWithLayer:(HMSSimulcastLayer)layer resolution:(CGSize)resolution;
@end


@interface HMSRemoteVideoTrack : HMSVideoTrack
@property (nonatomic, nullable) NSArray<HMSSimulcastLayerDefinition *> *layerDefinitions;
@property (nonatomic) HMSSimulcastLayer layer;

- (BOOL)isPlaybackAllowed;
- (void)setPlaybackAllowed:(BOOL)playbackAllowed;

@end

NS_ASSUME_NONNULL_END
