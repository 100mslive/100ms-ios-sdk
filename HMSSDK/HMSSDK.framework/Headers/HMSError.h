//
//  HMSError.h
//  HMSSDK
//
//  Created by codegen
//  Copyright © 2021 100ms. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * _Nonnull const kHMSVideoErrorDomain;

typedef NS_ENUM(NSInteger, HMSErrorCode) {
		
	// Connection Errors 
		
	// Generic error 
	kHMSGenericConnectErrorCode = 1000,
	// Auth token is missing 
	kHMSMissingTokenErrorCode = 1001,
	// Token is not in proper JWT format 
	kHMSInvalidTokenFormatErrorCode = 1002,
	// Token is missing room id parameter 
	kHMSTokenMissingRoomIdErrorCode = 1003,
	// SDK cannot establish websocket connection 
	kHMSNetworkUnavailableErrorCode = 1004,
	// Token is not authorised/expired 
	kHMSTokenNotAuthorisedErrorCode = 1005,
	// Endpoint url is malformed 
	kHMSInvalidEndpointUrlErrorCode = 1006,
	// Endpoint is not responding 
	kHMSEndpointUnreachableErrorCode = 1007,
	// Signalling websocket connection failed / RTC Peer connection failed 
	kHMSConnectionLostErrorCode = 1008,
		
	// Local Stream Errors 
		
	// Generic error 
	kHMSGenericStreamErrorCode = 2000,
	// Both publish audio/video is off nothing to return 
	kHMSNothingToReturnErrorCode = 2001,
	// Trying to change codec on the fly 
	kHMSCodecChangeNotPermittedErrorCode = 2002,
	// Trying to change publish video/audio mid call 
	kHMSPublishSettingsCantBeChangedErrorCode = 2003,
	// User denied permission to access capture device 
	kHMSCantAccessCaptureDeviceErrorCode = 2004,
	// WEB: Capture device is no longer available (usb cam is not connected) 
	kHMSDeviceNotAvailableErrorCode = 2005,
		
	// Room Join/Leave Errors 
		
	// Generic error 
	kHMSGenericJoinErrorCode = 3000,
	// Unknown room id 
	kHMSUnkownRoomErrorCode = 3001,
	// Already joined 
	kHMSAlreadyJoinedErrorCode = 3002,
	// Max room participants reached 
	kHMSRoomParticipantLimitReachedErrorCode = 3004,
		
	// Room Actions Errors 
		
	// Generic error 
	kHMSGenericActionErrorCode = 4100,
	// Has not joined the room 
	kHMSNotInTheRoomErrorCode = 4101,
	// Malformed server response (i.e sdp missing) 
	kHMSInvalidServerResponseErrorCode = 4102,
	// Failed to establish RTCPeerConnection 
	kHMSPeerConnectionFailedErrorCode = 4103,
		
	// Generic Errors 
		
	// Not connected 
	kHMSNotConnectedErrorCode = 5000,
	// Generic signalling error. I.e server is returning error response to some command but the SDK doesn't know how to handle. 
	kHMSSignallingErrorCode = 5001,
	// Generic SDK error. Some unforseen exception happened. 
	kHMSUknownErrorCode = 5002,
	// Webrtc stack not initialised yet 
	kHMSNotReadyErrorCode = 5003,
};



NS_ASSUME_NONNULL_BEGIN

/**
 `error` message will be sent from server to client in response the previously sent join or offer with id as message-id
 @code
 // Sample Error Message
 {
     "id":"message-id",
     "method":"error",
     "code":"<int>",
     "message":"error message"
 }
 @endcode
 */
@interface HMSError : NSError

@property (nonatomic, readonly) NSString *messageID;
@property (nonatomic, readonly) NSString *method;
@property (nonatomic, readonly) NSUInteger messageCode;
@property (nonatomic, readonly) NSString *message;
@property (nonatomic, readonly) NSString *resolution;

@end

NS_ASSUME_NONNULL_END
