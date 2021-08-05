//
//  HMSUtility.h
//  HMSSDK
//
//  Created by Dmitry Fedoseyev on 17.09.2020.
//  Copyright © 2020 100ms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMSCommonDefs.h"

NS_ASSUME_NONNULL_BEGIN

extern NSInteger const kHMSDefaultBitrate;

typedef struct HMSPerformanceStats
{
    double cpu;
    double memory;
    double battery;
} HMSPerformanceStats;


typedef NS_ENUM(NSUInteger, HMSConnectionRole) {
    kHMSConnectionRolePub,
    kHMSConnectionRoleSub
};

@interface HMSUtility : NSObject

+ (NSString *)codecStringFrom:(HMSCodec)codec;

+ (HMSCodec)codecFrom:(NSString *)string;

+ (HMSTrackSource)sourceFrom:(NSString *)string;

+ (NSString *)sourceStringFrom:(HMSTrackSource)source;

+ (NSString *)kindStringFrom:(HMSTrackKind)kind;

@end

@interface NSDate(HMSConvenience)
- (NSNumber *)timestampInMs;
@end

NS_ASSUME_NONNULL_END
