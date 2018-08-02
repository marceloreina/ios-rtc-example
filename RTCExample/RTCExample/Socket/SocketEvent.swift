//
//  SocketEvents.swift
//  RTCExample
//
//  Created by Marcelo Reina on 31/07/2018.
//  Copyright © 2018 Marcelo Reina. All rights reserved.
//

import Foundation

enum SocketEvent: String {
    case join = "join"
    case pong = "pong"
    case whoAmI = "whoami"
    case online = "online"
    case incoming = "incoming"
    case rejected = "rejected"
    case created = "created"
    case ready = "ready"
    case rtcMessage = "rtcmessage"
    case callRejected = "call-rejected"
    case callAnswered = "call-answered"
    case call = "call"
    case bye = "bye"
}
