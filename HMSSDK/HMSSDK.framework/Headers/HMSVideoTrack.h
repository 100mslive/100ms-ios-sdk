//
//  HMSSDKTrack.h
//  HMSSDK
//
//  Created by Dmitry Fedoseyev on 15.09.2020.
//  Copyright © 2020 100ms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMSTrack.h"

NS_ASSUME_NONNULL_BEGIN

@interface HMSVideoTrack : HMSTrack

- (BOOL)isDegraded;
- (void)addSink:(id)sink;
- (void)removeSink:(id)sink;

@end

NS_ASSUME_NONNULL_END
