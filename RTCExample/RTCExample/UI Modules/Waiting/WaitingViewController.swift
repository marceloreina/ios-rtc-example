//
//  WaitingViewController.swift
//  RTCExample
//
//  Created by Marcelo Reina on 31/07/2018.
//  Copyright © 2018 Marcelo Reina. All rights reserved.
//

import UIKit

protocol WaitingPresenterView: class {
    func presentCallingState(message: String)
    func presentReveivingCallState(message: String)
    func close(completion: @escaping () -> ())
}

class WaitingViewController: UIViewController {
    
    static let storyboardId: String = String(describing: WaitingViewController.self)
    let centerOffsetConstraintValue: CGFloat = -50.0
    
    var presenter: WaitingPresenterProtocol!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var answerButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var rejectButtonCenterConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.loadIntialState()
    }
    
    @IBAction func answerPressed(button: UIButton) {
        presenter.didAcceptCall()
    }
    
    @IBAction func rejectPressed(button: UIButton) {
        presenter.didRejectCall()
    }
}

extension WaitingViewController: WaitingPresenterView {
    
    func presentCallingState(message: String) {
        activityIndicator.startAnimating()
        messageLabel.text = message
        answerButton.isHidden = true
        rejectButtonCenterConstraint.constant = 0
    }
    
    func presentReveivingCallState(message: String) {
        activityIndicator.startAnimating()
        messageLabel.text = message
        answerButton.isHidden = false
        rejectButtonCenterConstraint.constant = centerOffsetConstraintValue
    }
    
    func close(completion: @escaping () -> ()) {
        dismiss(animated: true) {
            completion()
        }
    }
}
