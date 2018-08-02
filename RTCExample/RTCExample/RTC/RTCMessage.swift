//
//  RTCMessage.swift
//  RTCExample
//
//  Created by Marcelo Reina on 31/07/2018.
//  Copyright © 2018 Marcelo Reina. All rights reserved.
//

import Foundation

enum RTCMessageType: String {
    case offer = "offer"
    case answer = "answer"
    case candidate = "candidate"
    
    static func messageType(for payload: [String: Any]) -> RTCMessageType? {
        guard let typeString = payload["type"] as? String else {
            Log.shared.error("RTC payload with no type")
            return nil
        }
        
        return RTCMessageType(rawValue: typeString)
    }
}

protocol RTCMessageBuilderProtocol {
    func buildMessage() -> RTCMessage
}

protocol RTCMessageParserProtocol {
    associatedtype RTCSpecificMessage
    static func parse(payload: [String: Any]) -> RTCSpecificMessage?
}

struct RTCMessage {
    let event: SocketEvent = .rtcMessage
    let payload: [String: Any]
}

extension RTCMessage: SocketMessageData {
    typealias Element = RTCMessage
    
    static func create(data: [Any]) -> RTCMessage? {
        guard let payloadDictionary = data.first as? [String: Any] else {
            Log.shared.error("Unable to retrieve rtc payload from socket message")
            return nil
        }
        
        return RTCMessage(payload: payloadDictionary)
    }
}


