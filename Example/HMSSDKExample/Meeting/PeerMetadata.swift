//
//  PeerMetadata.swift
//  HMSSDKExample
//
//  Created by Dmitry Fedoseyev on 19.11.2021.
//  Copyright © 2021 100ms. All rights reserved.
//

import Foundation
import HMSSDK

struct PeerMetadata: Codable {
    let isHandRaised: Bool

    enum CodingKeys: String, CodingKey {
        case isHandRaised = "isHandRaised"
    }
}

extension HMSPeer {
    var peerMetadataObject: PeerMetadata? {
        guard let metadata = metadata,
              let data = metadata.data(using: .utf8) else {
            return nil
        }

        return try? JSONDecoder().decode(PeerMetadata.self, from: data)
    }
}

extension HMSSDK {
    func change(metadataObject: PeerMetadata, completion: ((Bool, HMSError?) -> Void)? = nil) {
        guard let data = try? JSONEncoder().encode(metadataObject),
              let dataString = String(data: data, encoding: .utf8) else {
            completion?(false, nil)
            return
        }

        change(metadata: dataString, completion: completion)
    }
}
