//
//  CallViewController.swift
//  RTCExample
//
//  Created by Marcelo Reina on 01/08/2018.
//  Copyright © 2018 Marcelo Reina. All rights reserved.
//

import UIKit
import WebRTC

protocol CallPresenterView: class {
    func close(completion: @escaping () -> ())
    func provideLocalVideoView() -> RTCCameraPreviewView
    func provideRemoteVideoView() -> UIView
}

class CallViewController: UIViewController {
    
    static let storyboardId: String = String(describing: CallViewController.self)
    
    var presenter: CallPresenterProtocol!
    
    @IBOutlet weak var remoteVideoView: UIView!
    @IBOutlet weak var localVideoView: RTCCameraPreviewView!

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.startRTC()
    }
    
    @IBAction func endCallPressed(button: UIButton) {
        presenter.endCallPressed()
    }

}

extension CallViewController: CallPresenterView {
    func close(completion: @escaping () -> ()) {
        dismiss(animated: true, completion: completion)
    }
    
    func provideLocalVideoView() -> RTCCameraPreviewView {
        return localVideoView
    }
    
    func provideRemoteVideoView() -> UIView {
        return remoteVideoView
    }
}
