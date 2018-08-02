//
//  WaitingPresenter.swift
//  RTCExample
//
//  Created by Marcelo Reina on 31/07/2018.
//  Copyright © 2018 Marcelo Reina. All rights reserved.
//

import Foundation

protocol WaitingPresenterProtocol: class {
    func loadIntialState()
    func didAcceptCall()
    func didRejectCall()
}

protocol WaitingPresenterDelegate: class {
    func didRejectCall(room: SocketRoom)
    func didAnswerCall(room: SocketRoom)
    func registerPassiveDelegate(delegate: WaitingPresenterPassiveInteractionProtocol)
}

protocol WaitingPresenterPassiveInteractionProtocol: class {
    func receivedRejectedCall(room: SocketRoom)
    func receivedRoomIsReady(room: SocketRoom, completion: @escaping () -> ())
}

class WaitingPresenter {
    let room: SocketRoom
    let isCalling: Bool
    weak var delegate: WaitingPresenterDelegate!
    weak var viewDelegate: WaitingPresenterView!
    
    init (room: SocketRoom, isCalling: Bool, delegate: WaitingPresenterDelegate, viewDelegate: WaitingPresenterView) {
        self.room = room
        self.isCalling = isCalling
        self.delegate = delegate
        self.viewDelegate = viewDelegate
        
        delegate.registerPassiveDelegate(delegate: self)
    }
}

extension WaitingPresenter: WaitingPresenterProtocol {
    
    func loadIntialState() {
        if isCalling {
            viewDelegate.presentCallingState(message: "calling \(room.targetUser.alias)")
        } else {
            viewDelegate.presentReveivingCallState(message: "\(room.targetUser.alias) is calling")
        }
    }
    
    func didAcceptCall() {
        delegate.didAnswerCall(room: room)
    }
    
    func didRejectCall() {
        delegate.didRejectCall(room: room)
        viewDelegate.close() {
            Log.shared.debug("Waiting view controlled was dismissed")
        }
    }
}

extension WaitingPresenter: WaitingPresenterPassiveInteractionProtocol {
    
    func receivedRejectedCall(room: SocketRoom) {
        viewDelegate.close() {
            Log.shared.debug("view is closed")
        }
    }
    
    func receivedRoomIsReady(room: SocketRoom, completion: @escaping () -> ()) {
        viewDelegate.close() {
            Log.shared.debug("view is closed")
            completion()
        }
    }
    
}
