//
//  CallPresenter.swift
//  RTCExample
//
//  Created by Marcelo Reina on 01/08/2018.
//  Copyright © 2018 Marcelo Reina. All rights reserved.
//

import Foundation
import WebRTC

protocol CallPresenterProtocol {
    func startRTC()
    func endCallPressed()
}

class CallPresenter {
    private weak var viewDelegate: CallPresenterView!
    private weak var rtcClient: RTCClientProtocol!
    
    init(viewDelegate: CallPresenterView, rtcClient: RTCClientProtocol) {
        self.viewDelegate = viewDelegate
        self.rtcClient = rtcClient
    }
}

extension CallPresenter: CallPresenterProtocol {
    
    func startRTC() {
        rtcClient.registerViewDelegate(viewDelegate: self)
    }
    
    func endCallPressed() {
        rtcClient.closeConnection()
        viewDelegate.close() {
        }
    }
}

extension CallPresenter: RTCClientViewDelegate {
    func setLocalPreviewSession(session: AVCaptureSession) {
        viewDelegate.provideLocalVideoView().captureSession = session
    }
    
    func provideViewForRemoteStream() -> UIView {
        return viewDelegate.provideRemoteVideoView()
    }
    
    
}
