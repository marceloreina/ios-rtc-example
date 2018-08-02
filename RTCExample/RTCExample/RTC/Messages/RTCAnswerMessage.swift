//
//  RTCAnswerMessage.swift
//  RTCExample
//
//  Created by Marcelo Reina on 01/08/2018.
//  Copyright © 2018 Marcelo Reina. All rights reserved.
//

import Foundation

struct RTCAnswerMessage {
    let type: RTCMessageType = .answer
    let sdp: String
}

extension RTCAnswerMessage: RTCMessageBuilderProtocol {
    func buildMessage() -> RTCMessage {
        var payload: [String: Any] = [String: Any]()
        payload["type"] = type.rawValue
        payload["sdp"] = sdp
        return RTCMessage(payload: payload)
    }
}

extension RTCAnswerMessage: RTCMessageParserProtocol {
    typealias RTCSpecificMessage = RTCAnswerMessage
    
    static func parse(payload: [String : Any]) -> RTCAnswerMessage? {
        guard let payloadSDP = payload["sdp"] as? String else {
            Log.shared.error("No sdp inside answer message")
            return nil
        }
        
        return RTCAnswerMessage(sdp: payloadSDP)
    }
}
