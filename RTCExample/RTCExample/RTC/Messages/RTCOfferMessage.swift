//
//  RTCOfferMessage.swift
//  RTCExample
//
//  Created by Marcelo Reina on 01/08/2018.
//  Copyright © 2018 Marcelo Reina. All rights reserved.
//

import Foundation

struct RTCOfferMessage {
    let type: RTCMessageType = .offer
    let sdp: String
}

extension RTCOfferMessage: RTCMessageBuilderProtocol {
    func buildMessage() -> RTCMessage {
        var payload: [String: Any] = [String: Any]()
        payload["type"] = type.rawValue
        payload["sdp"] = sdp
        return RTCMessage(payload: payload)
    }
}
extension RTCOfferMessage: RTCMessageParserProtocol {
    typealias RTCSpecificMessage = RTCOfferMessage
    
    static func parse(payload: [String : Any]) -> RTCOfferMessage? {
        guard let payloadSDP = payload["sdp"] as? String else {
            Log.shared.error("No sdp inside offer message")
            return nil
        }
        
        return RTCOfferMessage(sdp: payloadSDP)
    }
}
