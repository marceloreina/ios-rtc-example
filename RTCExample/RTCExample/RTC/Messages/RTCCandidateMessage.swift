//
//  RTCCandidateMessage.swift
//  RTCExample
//
//  Created by Marcelo Reina on 01/08/2018.
//  Copyright © 2018 Marcelo Reina. All rights reserved.
//

import Foundation

struct RTCCandidateMessage {
    let type: RTCMessageType = .candidate
    let candidate: String
    let id: String
    let label: Int32
}

extension RTCCandidateMessage: RTCMessageBuilderProtocol {
    func buildMessage() -> RTCMessage {
        var payload: [String: Any] = [String: Any]()
        payload["type"] = type.rawValue
        payload["candidate"] = candidate
        payload["id"] = id
        payload["label"] = label
        return RTCMessage(payload: payload)
    }
}

extension RTCCandidateMessage: RTCMessageParserProtocol {
    typealias RTCSpecificMessage = RTCCandidateMessage
    
    static func parse(payload: [String : Any]) -> RTCCandidateMessage? {
        guard let payloadCandidate = payload["candidate"] as? String else {
            Log.shared.error("No candidate inside candidate message")
            return nil
        }
        
        guard let payloadId = payload["id"] as? String else {
            Log.shared.error("No id inside candidate message")
            return nil
        }
        
        guard let payloadLabel = payload["label"] as? Int32 else {
            Log.shared.error("No id inside candidate message")
            return nil
        }
        
        return RTCCandidateMessage(candidate: payloadCandidate, id: payloadId, label: payloadLabel)
    }
}
