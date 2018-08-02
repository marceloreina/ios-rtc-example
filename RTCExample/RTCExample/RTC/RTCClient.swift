//
//  RTCClient.swift
//  RTCExample
//
//  Created by Marcelo Reina on 31/07/2018.
//  Copyright © 2018 Marcelo Reina. All rights reserved.
//

import Foundation
import WebRTC

protocol RTCClientProtocol: class {
    func registerViewDelegate(viewDelegate: RTCClientViewDelegate)
    func processMessage(_ message: RTCMessage)
    func closeConnection()
}

protocol RTCClientDelegate: class {
    func sendMessage(_ message: RTCMessage)
    func closeConnection()
}

protocol RTCClientViewDelegate: class {
    func setLocalPreviewSession(session: AVCaptureSession)
    func provideViewForRemoteStream() -> UIView
}

class RTCClient: NSObject {
    
    private let stunServerURL: String = "stun:stun.l.google.com:19302"
    private let mediaConstraints = RTCMediaConstraints(mandatoryConstraints: ["OfferToReceiveAudio": "true", "OfferToReceiveVideo": "true"], optionalConstraints: nil)
    
    private var connectionFactory: RTCPeerConnectionFactory? = nil
    private var peerConnection: RTCPeerConnection? = nil
    private var capturer: RTCCameraVideoCapturer? = nil
    private var remoteVideoTrack: RTCVideoTrack? = nil
    private var remoteVideoView: RTCMTLVideoView? = nil
    private var isCalling: Bool = false
    private var rtcMessages: [RTCMessage] = [RTCMessage]()
    
    private var remoteSDP: (sessionDescription: RTCSessionDescription, type: RTCSdpType)? = nil
    
    private weak var delegate: RTCClientDelegate!
    private weak var viewDelegate: RTCClientViewDelegate?
    
    init(delegate: RTCClientDelegate, isCalling: Bool) {
        self.delegate = delegate
        self.isCalling = isCalling
    }
    
    //MARK: - Initial Setup
    
    private func setup() {
        
        let config = RTCConfiguration()
        config.bundlePolicy = .balanced
        config.iceServers = [RTCIceServer(urlStrings: [stunServerURL])]
        
        connectionFactory = RTCPeerConnectionFactory()
        peerConnection = connectionFactory!.peerConnection(with: config, constraints: mediaConstraints, delegate: self)
        guard let localStream = createLocalStream() else {
            Log.shared.error("Unable to create local stream")
            return
        }
        peerConnection!.add(localStream)
        
        if isCalling {
            createOffer()
        } else {
            processStoredMessages()
        }
    }
    
    private func createLocalStream() -> RTCMediaStream? {
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            Log.shared.debug("Capture device access: \(granted)")
        }
        
        // create local stream
        guard let factory = connectionFactory else {
            Log.shared.error("No connection factory availabel - nil")
            return nil
        }
        let localStream = factory.mediaStream(withStreamId: UUID().uuidString)
        
        // add audio track
        let audioTrack = factory.audioTrack(withTrackId: UUID().uuidString)
        localStream.addAudioTrack(audioTrack)
        
        // add video track
        let videoSource: RTCVideoSource = factory.videoSource()
        guard let device = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: .video, position: .front) else {
            Log.shared.error("AVCaptureDevice failed")
            return nil
        }
        
        capturer = RTCCameraVideoCapturer(delegate: videoSource)
        capturer!.startCapture(with: device, format: device.activeFormat, fps: 30)
        
        let localVideoTrack = factory.videoTrack(with: videoSource, trackId: UUID().uuidString)
        localVideoTrack.isEnabled = true
        localStream.addVideoTrack(localVideoTrack)
        
        viewDelegate?.setLocalPreviewSession(session: capturer!.captureSession)
        
        
        return localStream
    }
    
    //MARK: - Offer and Answer creation
    
    private func createOffer() {
        peerConnection!.offer(for: mediaConstraints) { (sessionDescription, error) in
            guard error == nil else {
                Log.shared.error("Failed to create: \(error!)")
                return
            }
            
            guard sessionDescription != nil else {
                Log.shared.debug("No session description - nil")
                return
            }
            
            self.setLocalDescription(sessionDescription: sessionDescription!)
        }
    }
    
    private func createAnswer() {
        peerConnection!.answer(for: mediaConstraints) { (sessionDescription, error) in
            guard error == nil else {
                Log.shared.error("Failed to create: \(error!)")
                return
            }
            
            guard sessionDescription != nil else {
                Log.shared.error("No session description - nil")
                return
            }
            
            self.setLocalDescription(sessionDescription: sessionDescription!)
        }
    }
    
    //MARK: - Local and remote Description
    
    private func setRemoteDescription(sessionDescription: RTCSessionDescription) {
        peerConnection?.setRemoteDescription(sessionDescription) { (error) in
            guard error == nil else {
                Log.shared.error("Remote description failed: \(error!)")
                return
            }
            
            if sessionDescription.type == .offer {
                self.createAnswer()
            }
        }
    }
    
    private func setLocalDescription(sessionDescription: RTCSessionDescription) {
        peerConnection?.setLocalDescription(sessionDescription, completionHandler: { (error) in
            guard error == nil else {
                Log.shared.error("Set local failed: \(error!)")
                return
            }
            
            if sessionDescription.type == .offer {
                self.delegate.sendMessage(RTCOfferMessage(sdp: sessionDescription.sdp).buildMessage())
            } else {
                self.delegate.sendMessage(RTCAnswerMessage(sdp: sessionDescription.sdp).buildMessage())
            }
        })
    }
    
    private func processStoredMessages() {
        for message in rtcMessages {
            parseMessage(message)
        }
    }
    
    private func parseMessage(_ message: RTCMessage) {
        guard let messageType = RTCMessageType.messageType(for: message.payload) else {
            Log.shared.error("Invalid rtc message type")
            return
        }
        
        switch messageType {
        case .offer:
            guard let offerMessage = RTCOfferMessage.parse(payload: message.payload) else {
                Log.shared.error("Invalid offer message")
                return
            }
            setRemoteDescription(sessionDescription: RTCSessionDescription(type:.offer, sdp: offerMessage.sdp))
        case .answer:
            guard let answerMessage = RTCAnswerMessage.parse(payload: message.payload) else {
                Log.shared.error("Invalid answer message")
                return
            }
            setRemoteDescription(sessionDescription: RTCSessionDescription(type:.answer, sdp: answerMessage.sdp))
        case .candidate:
            guard let candidateMessage = RTCCandidateMessage.parse(payload: message.payload) else {
                Log.shared.error("Invalid candidate message")
                return
            }
            let iceCanditate = RTCIceCandidate(sdp: candidateMessage.candidate, sdpMLineIndex: candidateMessage.label, sdpMid: candidateMessage.id)
            peerConnection?.add(iceCanditate)
        }
    }
}

extension RTCClient: RTCClientProtocol {
    
    func registerViewDelegate(viewDelegate: RTCClientViewDelegate) {
        self.viewDelegate = viewDelegate
        setup()
    }
    
    func processMessage(_ message: RTCMessage) {
        if peerConnection != nil {
            parseMessage(message)
        } else {
            rtcMessages.append(message)
        }
    }
    
    func closeConnection() {
        peerConnection?.close()
        capturer?.stopCapture()
        remoteVideoTrack = nil
        remoteVideoView = nil
        capturer = nil
        peerConnection = nil
        
        delegate.closeConnection()
    }
    
}

extension RTCClient: RTCPeerConnectionDelegate {
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        
        if stream.videoTracks.count > 0 {
            guard let videoTrack = stream.videoTracks.first else {
                Log.shared.error("no remote video track")
                return
            }

            self.remoteVideoTrack = videoTrack
            self.remoteVideoTrack!.isEnabled = true

            guard let remoteVideoView = viewDelegate?.provideViewForRemoteStream() else {
                Log.shared.error("no remote view provided")
                return
            }

            DispatchQueue.main.async {
                self.remoteVideoView = RTCMTLVideoView(frame: remoteVideoView.bounds)
                remoteVideoView.addSubview(self.remoteVideoView!)
                self.remoteVideoTrack!.add(self.remoteVideoView!)

                let session = AVAudioSession()
                let _ = try? session.setInputGain(1.0)
                let _ = try? session.overrideOutputAudioPort(.speaker)
            }
        }
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        delegate.sendMessage(RTCCandidateMessage(candidate: candidate.sdp, id: candidate.sdpMid!, label: candidate.sdpMLineIndex).buildMessage())
    }
    
    //MARK: - To be continued ...
    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {}
    public func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {}
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {}
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {}
    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {}
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {}
    public func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {}
    
}
