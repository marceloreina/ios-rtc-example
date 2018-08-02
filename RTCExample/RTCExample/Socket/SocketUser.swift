//
//  SocketUser.swift
//  RTCExample
//
//  Created by Marcelo Reina on 31/07/2018.
//  Copyright © 2018 Marcelo Reina. All rights reserved.
//

import Foundation

struct SocketUser {
    let alias: String
    let id: String
    
    init(alias: String, id: String) {
        self.alias = alias
        self.id = id
    }
}

extension SocketUser: SocketMessageObject {
    typealias Element = SocketUser
    
    static func create(data: [String : Any]) -> SocketUser? {
        
        guard let userAlias = data["alias"] as? String else {
            Log.shared.error("No alias inside user")
            return nil
        }
        
        guard let userId = data["id"] as? String else {
            Log.shared.error("No id inside user")
            return nil
        }
        
        return SocketUser(alias: userAlias, id: userId)
    }
}

struct OnlineUserList {
    let users: [SocketUser]
}

extension OnlineUserList: SocketMessageData {
    typealias Element = OnlineUserList
    
    static func create(data: [Any]) -> OnlineUserList? {
        guard let userDictionaryArray = data.first as? [[String: Any]] else {
            Log.shared.error("Unable to retrieve online user list from socket message")
            return nil
        }
        
        var onlineUsers = [SocketUser]()
        for userDictionary in userDictionaryArray {
            guard let user = SocketUser.create(data: userDictionary) else {
                continue
            }
            onlineUsers.append(user)
        }
        return OnlineUserList(users: onlineUsers)
    }
}



