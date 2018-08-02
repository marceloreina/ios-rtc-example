//
//  Socket.swift
//  RTCExample
//
//  Created by Marcelo Reina on 30/07/2018.
//  Copyright © 2018 Marcelo Reina. All rights reserved.
//

import Foundation
import SocketIO

protocol SocketDelegate: class {
    func didConnect()
    func didDisconnect()
    func didReceiveOnlineUserList(_ onlineUsers: [SocketUser])
    func didReceiveIncomingCall(room: SocketRoom)
    func didCreateRoomForCall(room: SocketRoom)
    func roomIsReady(room: SocketRoom, rtcClient: RTCClientProtocol)
    func callAttemptWasRejected(room: SocketRoom)
}

protocol SocketProtocol {
    func connect(username: String, delegate: SocketDelegate)
    func disconnect()
    func rejectCall(room: SocketRoom)
    func answerCall(room: SocketRoom)
    func call(target: SocketUser)
}

protocol SocketMessageData {
    associatedtype Element
    static func create(data: [Any]) -> Element?
}

protocol SocketMessageObject {
    associatedtype Element
    static func create(data: [String: Any]) -> Element?
}


class Socket {
    
    private let manager = SocketManager(socketURL: URL(string: "http://localhost:8081")!, config: [.log(false), .compress])

    private var username: String = ""
    private var defaultSocket: SocketIOClient
    private weak var delegate: SocketDelegate? = nil
    private var currentActiveRoom: SocketRoom? = nil
    private var isCalling: Bool = false
    
    private var rtcClient: RTCClientProtocol? = nil
    
    init() {
        defaultSocket = manager.defaultSocket
    }
}

extension Socket: SocketProtocol {
    
    func connect(username: String, delegate: SocketDelegate) {
        
        self.username = username
        self.delegate = delegate
        
        //MARK: - Default client events
        
        // CONNECT
        defaultSocket.on(clientEvent: .connect) {data, ack in
            self.defaultSocket.emit(SocketEvent.join.rawValue, with: [username])
        }
        
        // PING
        defaultSocket.on(clientEvent: .ping) {data, ack in
            self.defaultSocket.emit(SocketEvent.pong.rawValue, with: [])
        }
        
        // DISCONNECT
        defaultSocket.on(clientEvent: .disconnect) { (data, ack) in
            self.username = ""
            self.currentActiveRoom = nil
            self.delegate?.didDisconnect()
        }
        
        //MARK: -  Custom socket events
        
        // WHO AM I
        defaultSocket.on(SocketEvent.whoAmI.rawValue) {data, ack in
            self.delegate?.didConnect()
        }
        
        // ONLINE
        defaultSocket.on(SocketEvent.online.rawValue) {data, ack in
            guard let onlineUsers = OnlineUserList.create(data: data) else {
                Log.shared.error("Invalid online user list")
                return
            }
            self.delegate?.didReceiveOnlineUserList(onlineUsers.users)
        }
        
        // INCOMING
        defaultSocket.on(SocketEvent.incoming.rawValue) {data, ack in
            guard let room = SocketRoom.create(data: data) else {
                Log.shared.error("Invalid room")
                return
            }
            self.currentActiveRoom = room
            self.isCalling = false
            self.delegate?.didReceiveIncomingCall(room: room)
        }
        
        // REJECTED
        defaultSocket.on(SocketEvent.rejected.rawValue)  {data, ack in
            guard let room = self.currentActiveRoom else {
                Log.shared.error("No current active room to be rejected")
                return
            }
            self.delegate?.callAttemptWasRejected(room: room)
        }
        
        // CREATED
        defaultSocket.on(SocketEvent.created.rawValue)  {data, ack in
            guard let dataArray = data as? [String] else {
                Log.shared.error("No room id inside created socket message")
                return
            }
            
            guard let roomId = dataArray.first else {
                Log.shared.error("No room id inside created socket message")
                return
            }
            
            guard let targetUser = self.currentActiveRoom?.targetUser else {
                Log.shared.error("No target user set before")
                return
            }
            
            self.currentActiveRoom = SocketRoom(roomId: roomId, targetUser: targetUser)
            self.delegate?.didCreateRoomForCall(room: self.currentActiveRoom!)
        }
        
        // READY
        defaultSocket.on(SocketEvent.ready.rawValue)  {data, ack in
            guard let room = self.currentActiveRoom else {
                Log.shared.error("Current active room is empty while receiving ready event")
                return
            }
            self.rtcClient = RTCClient(delegate: self, isCalling: self.isCalling)
            self.delegate?.roomIsReady(room: room, rtcClient: self.rtcClient!)            
        }
        
        // RTC MESSAGE
        defaultSocket.on(SocketEvent.rtcMessage.rawValue) {data, ack in
            guard let rtcMessage = RTCMessage.create(data: data) else {
                Log.shared.error("Failed to parse rtc message")
                return
            }
            self.rtcClient?.processMessage(rtcMessage)
        }
        
        defaultSocket.connect()
    }
    
    func disconnect() {
        defaultSocket.disconnect()
    }
    
    func rejectCall(room: SocketRoom) {
        defaultSocket.emit(SocketEvent.callRejected.rawValue, with: [room.roomId])
    }
    
    func answerCall(room: SocketRoom) {
        defaultSocket.emit(SocketEvent.callAnswered.rawValue, with: [room.roomId])
    }
    
    func call(target: SocketUser) {
        defaultSocket.emit(SocketEvent.call.rawValue, with: [target.id])
        currentActiveRoom = SocketRoom(roomId: "", targetUser: target)
        isCalling = true
    }
    
}

extension Socket: RTCClientDelegate {
    func sendMessage(_ message: RTCMessage) {
        defaultSocket.emit(SocketEvent.rtcMessage.rawValue, message.payload)
    }
    
    func closeConnection() {
        defaultSocket.emit(SocketEvent.bye.rawValue, with: [])
        currentActiveRoom = nil
        rtcClient = nil
    }
}

