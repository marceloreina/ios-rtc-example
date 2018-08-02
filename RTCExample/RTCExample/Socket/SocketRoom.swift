//
//  SocketRoom.swift
//  RTCExample
//
//  Created by Marcelo Reina on 31/07/2018.
//  Copyright © 2018 Marcelo Reina. All rights reserved.
//

import Foundation

struct SocketRoom {
    let roomId: String
    let targetUser: SocketUser
}

extension SocketRoom: SocketMessageData {
    typealias Element = SocketRoom
    
    static func create(data: [Any]) -> SocketRoom? {
        
        guard let roomDictionary = data.first as? [String: Any] else {
            Log.shared.error("Unable to retrieve room dictionary from socket message")
            return nil
        }
        
        guard let id = roomDictionary["room"] as? String else {
            Log.shared.error("Unable to retrieve room id from socket message")
            return nil
        }
        
        guard let user = SocketUser.create(data: roomDictionary) else {
            Log.shared.error("Invalid target user from socket message")
            return nil
        }
        
        return SocketRoom(roomId: id, targetUser: user)
    }
}
