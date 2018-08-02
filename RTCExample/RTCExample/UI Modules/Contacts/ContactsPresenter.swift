//
//  ContactsPresenter.swift
//  RTCExample
//
//  Created by Marcelo Reina on 30/07/2018.
//  Copyright © 2018 Marcelo Reina. All rights reserved.
//

import Foundation

protocol ContactsPresenterProtocol: class {
    func connect(username: String)
    func call(target: SocketUser)
}

class ContactsPresenter {
    let socket: SocketProtocol
    weak var viewDelegate: ContactsPresenterView!
    
    weak var waitingPresenterDelegate: WaitingPresenterPassiveInteractionProtocol?
    
    init(socket: SocketProtocol, delegate: ContactsPresenterView) {
        self.socket = socket
        self.viewDelegate = delegate
    }
}

extension ContactsPresenter: ContactsPresenterProtocol {
    func connect(username: String) {
        socket.connect(username: username, delegate: self)
    }
    
    func call(target: SocketUser) {
        socket.call(target: target)
    }
}

extension ContactsPresenter: SocketDelegate {
    
    func didConnect() {
        Log.shared.debug("Connected!")
    }
    
    func didDisconnect() {
        Log.shared.debug("disconnected!")
    }
    
    func didReceiveOnlineUserList(_ onlineUsers: [SocketUser]) {
        viewDelegate.showContactList(contacts: onlineUsers)
    }
    
    func didReceiveIncomingCall(room: SocketRoom) {
        let viewController = WaitingBuilder.build(room: room, isCalling: false, waitingPresenterDelegate: self)
        viewDelegate.showViewController(viewController: viewController)
    }
    
    func didCreateRoomForCall(room: SocketRoom) {
        let viewController = WaitingBuilder.build(room: room, isCalling: true, waitingPresenterDelegate: self)
        viewDelegate.showViewController(viewController: viewController)
    }
    
    func roomIsReady(room: SocketRoom, rtcClient: RTCClientProtocol) {
        waitingPresenterDelegate?.receivedRoomIsReady(room: room) {
            let callViewController = CallBuilder.build(rtcClient: rtcClient)
            self.viewDelegate.showViewController(viewController: callViewController)
        }
    }
    
    func callAttemptWasRejected(room: SocketRoom) {
        waitingPresenterDelegate?.receivedRejectedCall(room: room)
    }
}

extension ContactsPresenter: WaitingPresenterDelegate {
    
    func registerPassiveDelegate(delegate: WaitingPresenterPassiveInteractionProtocol) {
        waitingPresenterDelegate = delegate
    }
    
    func didRejectCall(room: SocketRoom) {
        socket.rejectCall(room: room)
    }
    
    func didAnswerCall(room: SocketRoom) {
        socket.answerCall(room: room)
    }    
}


