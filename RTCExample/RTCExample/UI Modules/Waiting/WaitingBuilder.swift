//
//  WaitingBuilder.swift
//  RTCExample
//
//  Created by Marcelo Reina on 31/07/2018.
//  Copyright © 2018 Marcelo Reina. All rights reserved.
//

import Foundation
import UIKit

struct WaitingBuilder {
    static func build(room: SocketRoom, isCalling: Bool, waitingPresenterDelegate: WaitingPresenterDelegate) -> UIViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle(for: WaitingViewController.self))
        
        let viewControllerIdentifier = WaitingViewController.storyboardId
        guard let waitingViewController = storyBoard.instantiateViewController(withIdentifier: viewControllerIdentifier) as? WaitingViewController else {
            Log.shared.error("No view controller found for \(viewControllerIdentifier)")
            fatalError()
        }
        
        let presenter = WaitingPresenter(room: room, isCalling: isCalling, delegate: waitingPresenterDelegate, viewDelegate: waitingViewController)
        waitingViewController.presenter = presenter
        
        return waitingViewController
    }
}
